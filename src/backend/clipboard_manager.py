#!/usr/bin/env python3
import os
import sys
import json
import sqlite3
import hashlib
import re
import subprocess
import time
from pathlib import Path

DB_DIR = Path.home() / ".local/share/omnicast"
DB_PATH = DB_DIR / "clipboard.db"
IMG_DIR = DB_DIR / "images"

def init_db():
    DB_DIR.mkdir(parents=True, exist_ok=True)
    IMG_DIR.mkdir(parents=True, exist_ok=True)
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS clipboard_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            hash TEXT UNIQUE,
            content_type TEXT,
            sub_type TEXT,
            text_content TEXT,
            image_path TEXT,
            preview_title TEXT,
            preview_subtitle TEXT,
            char_count INTEGER,
            line_count INTEGER,
            word_count INTEGER,
            dimensions TEXT,
            file_size INTEGER,
            is_pinned INTEGER DEFAULT 0,
            created_at INTEGER
        )
    """)
    
    # Check and migrate columns if upgrading from earlier version
    cursor.execute("PRAGMA table_info(clipboard_entries)")
    existing_cols = [row[1] for row in cursor.fetchall()]
    
    if "sub_type" not in existing_cols:
        cursor.execute("ALTER TABLE clipboard_entries ADD COLUMN sub_type TEXT DEFAULT ''")
    if "word_count" not in existing_cols:
        cursor.execute("ALTER TABLE clipboard_entries ADD COLUMN word_count INTEGER DEFAULT 0")
    if "dimensions" not in existing_cols:
        cursor.execute("ALTER TABLE clipboard_entries ADD COLUMN dimensions TEXT DEFAULT ''")
    if "file_size" not in existing_cols:
        cursor.execute("ALTER TABLE clipboard_entries ADD COLUMN file_size INTEGER DEFAULT 0")
        
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_hash ON clipboard_entries(hash)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_type ON clipboard_entries(content_type)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_pinned ON clipboard_entries(is_pinned DESC, created_at DESC)")
    conn.commit()
    conn.close()

def hex_to_rgb(hex_str):
    hex_str = hex_str.lstrip('#')
    if len(hex_str) == 3:
        hex_str = ''.join([c*2 for c in hex_str])
    r = int(hex_str[0:2], 16)
    g = int(hex_str[2:4], 16)
    b = int(hex_str[4:6], 16)
    return r, g, b

def rgb_to_hsl(r, g, b):
    r_norm, g_norm, b_norm = r / 255.0, g / 255.0, b / 255.0
    cmax = max(r_norm, g_norm, b_norm)
    cmin = min(r_norm, g_norm, b_norm)
    delta = cmax - cmin
    
    l = (cmax + cmin) / 2.0
    if delta == 0:
        h = 0
        s = 0
    else:
        s = delta / (1 - abs(2 * l - 1))
        if cmax == r_norm:
            h = ((g_norm - b_norm) / delta) % 6
        elif cmax == g_norm:
            h = (b_norm - r_norm) / delta + 2
        else:
            h = (r_norm - g_norm) / delta + 4
        h = round(h * 60)
        
    s = round(s * 100)
    l = round(l * 100)
    return f"hsl({h}, {s}%, {l}%)"

def detect_code_language(text):
    text_sample = text[:500].strip()
    if text_sample.startswith("{") or text_sample.startswith("["):
        try:
            json.loads(text)
            return "json"
        except:
            pass
    if "def " in text_sample or "import " in text_sample or "print(" in text_sample:
        return "python"
    if "const " in text_sample or "let " in text_sample or "=>" in text_sample or "console.log" in text_sample:
        return "javascript"
    if "fn " in text_sample or "let mut " in text_sample or "impl " in text_sample:
        return "rust"
    if "<html" in text_sample or "<div" in text_sample or "/>" in text_sample:
        return "html"
    if "SELECT " in text_sample.upper() or "INSERT INTO" in text_sample.upper() or "WHERE " in text_sample.upper():
        return "sql"
    if text_sample.startswith("#!") or "sudo " in text_sample or "grep " in text_sample or "echo " in text_sample:
        return "bash"
    return ""

def detect_content_type(text):
    if not text:
        return "text", "text", "📄"
    text_strip = text.strip()
    
    # Hex or RGB color (#fff, #ffffff, rgb(255, 0, 0))
    if re.match(r"^#(?:[0-9a-fA-F]{3}){1,2}$", text_strip) or re.match(r"^rgba?\([\d\s,\.]+\)$", text_strip):
        return "color", "color", "🎨"
    
    # URL
    if re.match(r"^https?:\/\/[^\s]+$", text_strip):
        return "url", "url", "🌐"
        
    # Code detection
    lang = detect_code_language(text)
    if lang or "\n" in text or (len(text) > 120 and ("=" in text or "(" in text)):
        return "code", lang or "code", ""
        
    return "text", "text", "📄"

def capture_text(text):
    if not text or not text.strip():
        return
    text = text.strip()
    
    if len(text) > 50000:
        text = text[:50000]
        
    content_hash = hashlib.sha256(text.encode("utf-8")).hexdigest()
    content_type, sub_type, icon = detect_content_type(text)
    
    lines = text.split("\n")
    line_count = len(lines)
    char_count = len(text)
    word_count = len(text.split())
    
    first_line = lines[0][:75]
    preview_title = first_line + ("..." if len(lines[0]) > 75 or line_count > 1 else "")
    preview_subtitle = f"{content_type.capitalize()} • {char_count} chars"
    now = int(time.time())
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO clipboard_entries (hash, content_type, sub_type, text_content, image_path, preview_title, preview_subtitle, char_count, line_count, word_count, created_at)
        VALUES (?, ?, ?, ?, '', ?, ?, ?, ?, ?, ?)
        ON CONFLICT(hash) DO UPDATE SET
            created_at = excluded.created_at
    """, (content_hash, content_type, sub_type, text, preview_title, preview_subtitle, char_count, line_count, word_count, now))
    conn.commit()
    conn.close()

def capture_image_bytes(img_data):
    if not img_data or len(img_data) < 100:
        return
        
    content_hash = hashlib.sha256(img_data).hexdigest()
    img_path = IMG_DIR / f"{content_hash}.png"
    
    if not img_path.exists():
        with open(img_path, "wb") as f:
            f.write(img_data)
            
    file_size = len(img_data)
    dimensions = "Image Preview"
    
    try:
        proc = subprocess.run(["file", str(img_path)], capture_output=True, text=True)
        out = proc.stdout
        dim_match = re.search(r'(\d+)\s*x\s*(\d+)', out)
        if dim_match:
            dimensions = f"{dim_match.group(1)}×{dim_match.group(2)}"
    except:
        pass
        
    preview_title = f"Screenshot / Image ({dimensions})"
    preview_subtitle = f"PNG • {file_size // 1024} KB"
    now = int(time.time())
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO clipboard_entries (hash, content_type, sub_type, text_content, image_path, preview_title, preview_subtitle, char_count, line_count, word_count, dimensions, file_size, created_at)
        VALUES (?, 'image', 'png', '', ?, ?, ?, 0, 0, 0, ?, ?, ?)
        ON CONFLICT(hash) DO UPDATE SET
            created_at = excluded.created_at
    """, (content_hash, str(img_path), preview_title, preview_subtitle, dimensions, file_size, now))
    conn.commit()
    conn.close()

def toggle_pin(entry_id):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("UPDATE clipboard_entries SET is_pinned = 1 - is_pinned WHERE id = ?", (entry_id,))
    conn.commit()
    conn.close()

def list_entries(query="", filter_type="all", limit=60):
    init_db()
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    where_clauses = []
    params = []
    
    if filter_type == "pinned":
        where_clauses.append("is_pinned = 1")
    elif filter_type in ["text", "code", "color", "url", "image"]:
        where_clauses.append("content_type = ?")
        params.append(filter_type)
        
    if query and query.strip():
        q_wild = f"%{query.strip()}%"
        where_clauses.append("(text_content LIKE ? OR preview_title LIKE ? OR dimensions LIKE ?)")
        params.extend([q_wild, q_wild, q_wild])
        
    where_sql = f"WHERE {' AND '.join(where_clauses)}" if where_clauses else ""
    
    sql = f"""
        SELECT id, content_type, sub_type, text_content, image_path, preview_title, preview_subtitle, char_count, line_count, word_count, dimensions, file_size, is_pinned, created_at
        FROM clipboard_entries
        {where_sql}
        ORDER BY is_pinned DESC, created_at DESC
        LIMIT ?
    """
    params.append(limit)
    
    cursor.execute(sql, tuple(params))
    rows = cursor.fetchall()
    conn.close()
    
    results = []
    now = int(time.time())
    for r in rows:
        cid, ctype, stype, text, img, title, subtitle, chars, lines, words, dims, fsize, pinned, ts = r
        
        diff = now - ts
        if diff < 60:
            time_ago = "Just now"
        elif diff < 3600:
            time_ago = f"{diff // 60}m ago"
        elif diff < 86400:
            time_ago = f"{diff // 3600}h ago"
        else:
            time_ago = f"{diff // 86400}d ago"
            
        icon = "📌" if pinned else ("🖼️" if ctype == "image" else ("🎨" if ctype == "color" else ("🌐" if ctype == "url" else ("" if ctype == "code" else "📄"))))
        
        metadata = []
        markdown = ""
        
        if ctype == "image":
            markdown = f"### Image Preview\n\n**Dimensions:** `{dims}`\n**File Size:** `{fsize // 1024} KB`\n\nPress **↵** to paste image into active application."
            metadata = [
                { "label": "Type", "value": "PNG Image" },
                { "label": "Dimensions", "value": dims },
                { "label": "File Size", "value": f"{fsize // 1024} KB" },
                { "label": "Status", "value": "📌 Pinned" if pinned else "Recent" },
                { "label": "Recorded", "value": time_ago }
            ]
        elif ctype == "color":
            clean_hex = text.strip()
            rgb_str = ""
            hsl_str = ""
            if clean_hex.startswith("#"):
                try:
                    r, g, b = hex_to_rgb(clean_hex)
                    rgb_str = f"rgb({r}, {g}, {b})"
                    hsl_str = rgb_to_hsl(r, g, b)
                except:
                    pass
            markdown = f"### Color Swatch: `{clean_hex}`\n\n- **HEX:** `{clean_hex}`\n- **RGB:** `{rgb_str}`\n- **HSL:** `{hsl_str}`\n\nPress **↵** to paste, **Ctrl+C** to copy hex."
            metadata = [
                { "label": "Type", "value": "Color Swatch" },
                { "label": "HEX", "value": clean_hex },
                { "label": "RGB", "value": rgb_str or "N/A" },
                { "label": "HSL", "value": hsl_str or "N/A" },
                { "label": "Status", "value": "📌 Pinned" if pinned else "Recent" }
            ]
        elif ctype == "url":
            clean_url = text.strip()
            domain_match = re.search(r'https?:\/\/([^\/\s]+)', clean_url)
            domain = domain_match.group(1) if domain_match else clean_url
            markdown = f"### Web Link\n\n[{clean_url}]({clean_url})\n\n- **Domain:** `{domain}`\n\nPress **↵** to copy, **Ctrl+O** to open in browser."
            metadata = [
                { "label": "Type", "value": "Web Link" },
                { "label": "Domain", "value": domain },
                { "label": "Length", "value": f"{chars} chars" },
                { "label": "Status", "value": "📌 Pinned" if pinned else "Recent" }
            ]
        elif ctype == "code":
            lang = stype if stype != "code" else ""
            markdown = f"```{lang}\n{text[:2500]}\n```"
            metadata = [
                { "label": "Type", "value": f"Code ({lang.upper() or 'Snippet'})" },
                { "label": "Lines", "value": f"{lines} lines" },
                { "label": "Characters", "value": f"{chars} chars" },
                { "label": "Words", "value": f"{words} words" },
                { "label": "Status", "value": "📌 Pinned" if pinned else "Recent" }
            ]
        else:
            markdown = f"{text[:2500]}"
            metadata = [
                { "label": "Type", "value": "Plain Text" },
                { "label": "Characters", "value": f"{chars} chars" },
                { "label": "Words", "value": f"{words} words" },
                { "label": "Lines", "value": f"{lines} lines" },
                { "label": "Status", "value": "📌 Pinned" if pinned else "Recent" }
            ]
            
        results.append({
            "id": f"clip-{cid}",
            "raw_id": cid,
            "title": title,
            "subtitle": f"{time_ago} • {subtitle}",
            "icon": icon,
            "badge": ("📌 " if pinned else "") + ctype.capitalize(),
            "contentType": ctype,
            "content": text,
            "imagePath": img,
            "image": f"file://{img}" if img else "",
            "markdown": markdown,
            "color": text if ctype == "color" else "",
            "isPinned": bool(pinned),
            "metadata": metadata
        })
        
    return results

def delete_entry(cid):
    init_db()
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("DELETE FROM clipboard_entries WHERE id = ?", (cid,))
    conn.commit()
    conn.close()

def clear_all():
    init_db()
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("DELETE FROM clipboard_entries WHERE is_pinned = 0")
    conn.commit()
    conn.close()

if __name__ == "__main__":
    init_db()
    cmd = sys.argv[1] if len(sys.argv) > 1 else "list"
    
    if cmd == "list":
        query = sys.argv[2] if len(sys.argv) > 2 else ""
        ftype = sys.argv[3] if len(sys.argv) > 3 else "all"
        print(json.dumps(list_entries(query, ftype)))
    elif cmd == "capture":
        if len(sys.argv) > 2:
            capture_text(sys.argv[2])
        else:
            content = sys.stdin.read()
            capture_text(content)
    elif cmd == "capture-image":
        img_bytes = sys.stdin.buffer.read()
        capture_image_bytes(img_bytes)
    elif cmd == "pin":
        if len(sys.argv) > 2:
            toggle_pin(int(sys.argv[2].replace("clip-", "")))
            print(json.dumps({"status": "toggled"}))
    elif cmd == "delete":
        if len(sys.argv) > 2:
            delete_entry(int(sys.argv[2].replace("clip-", "")))
            print(json.dumps({"status": "deleted"}))
    elif cmd == "clear":
        clear_all()
        print(json.dumps({"status": "cleared"}))
