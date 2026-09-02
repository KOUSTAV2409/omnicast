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
            text_content TEXT,
            image_path TEXT,
            preview_title TEXT,
            preview_subtitle TEXT,
            char_count INTEGER,
            line_count INTEGER,
            is_pinned INTEGER DEFAULT 0,
            created_at INTEGER
        )
    """)
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_hash ON clipboard_entries(hash)")
    cursor.execute("CREATE INDEX IF NOT EXISTS idx_created_at ON clipboard_entries(created_at DESC)")
    conn.commit()
    conn.close()

def detect_content_type(text):
    if not text:
        return "text", "📄"
    text_strip = text.strip()
    
    # Hex color (#fff, #ffffff, #ffffffaa)
    if re.match(r"^#(?:[0-9a-fA-F]{3}){1,2}$", text_strip) or re.match(r"^rgba?\(.+\)$", text_strip):
        return "color", "🎨"
    
    # URL
    if re.match(r"^https?:\/\/[^\s]+$", text_strip):
        return "url", "🌐"
        
    # JSON
    if (text_strip.startswith("{") and text_strip.endswith("}")) or (text_strip.startswith("[") and text_strip.endswith("]")):
        try:
            json.loads(text_strip)
            return "code", ""
        except:
            pass
            
    # Code patterns (bash, js, python, sql)
    code_keywords = ["function ", "def ", "import ", "const ", "let ", "var ", "class ", "return ", "SELECT ", "UPDATE ", "#!/"]
    if any(kw in text for kw in code_keywords) or "\n" in text:
        return "code", ""
        
    return "text", "📄"

def capture_text(text):
    if not text or not text.strip():
        return
    text = text.strip()
    content_hash = hashlib.sha256(text.encode("utf-8")).hexdigest()
    content_type, icon = detect_content_type(text)
    
    lines = text.split("\n")
    line_count = len(lines)
    char_count = len(text)
    
    first_line = lines[0][:80]
    preview_title = first_line + ("..." if len(lines[0]) > 80 or line_count > 1 else "")
    preview_subtitle = f"{content_type.capitalize()} • {char_count} chars"
    now = int(time.time())
    
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO clipboard_entries (hash, content_type, text_content, image_path, preview_title, preview_subtitle, char_count, line_count, created_at)
        VALUES (?, ?, ?, '', ?, ?, ?, ?, ?)
        ON CONFLICT(hash) DO UPDATE SET
            created_at = excluded.created_at
    """, (content_hash, content_type, text, preview_title, preview_subtitle, char_count, line_count, now))
    conn.commit()
    conn.close()

def list_entries(query="", limit=50):
    init_db()
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    if query and query.strip():
        q_wild = f"%{query.strip()}%"
        cursor.execute("""
            SELECT id, content_type, text_content, image_path, preview_title, preview_subtitle, char_count, line_count, is_pinned, created_at
            FROM clipboard_entries
            WHERE text_content LIKE ? OR preview_title LIKE ?
            ORDER BY is_pinned DESC, created_at DESC
            LIMIT ?
        """, (q_wild, q_wild, limit))
    else:
        cursor.execute("""
            SELECT id, content_type, text_content, image_path, preview_title, preview_subtitle, char_count, line_count, is_pinned, created_at
            FROM clipboard_entries
            ORDER BY is_pinned DESC, created_at DESC
            LIMIT ?
        """, (limit,))
        
    rows = cursor.fetchall()
    conn.close()
    
    results = []
    now = int(time.time())
    for r in rows:
        cid, ctype, text, img, title, subtitle, chars, lines, pinned, ts = r
        
        # Format time ago
        diff = now - ts
        if diff < 60:
            time_ago = "Just now"
        elif diff < 3600:
            time_ago = f"{diff // 60}m ago"
        elif diff < 86400:
            time_ago = f"{diff // 3600}h ago"
        else:
            time_ago = f"{diff // 86400}d ago"
            
        icon = "🎨" if ctype == "color" else ("🌐" if ctype == "url" else ("" if ctype == "code" else "📄"))
        
        # Build markdown preview
        if ctype == "code":
            markdown = f"```\n{text[:1200]}\n```"
        elif ctype == "color":
            markdown = f"### Color Swatch: `{text}`\n\n- **Hex Code:** `{text}`\n- **Role:** Palette Color\n\nPress **↵** to copy."
        elif ctype == "url":
            markdown = f"### URL Link\n\n[{text}]({text})\n\nPress **↵** to copy, or **Ctrl+O** to open in browser."
        else:
            markdown = f"{text[:1200]}"
            
        results.append({
            "id": f"clip-{cid}",
            "title": title,
            "subtitle": f"{time_ago} • {chars} chars",
            "icon": icon,
            "badge": ctype.capitalize(),
            "content": text,
            "markdown": markdown,
            "color": text if ctype == "color" else "",
            "metadata": [
                { "label": "Type", "value": ctype.capitalize() },
                { "label": "Characters", "value": f"{chars} characters" },
                { "label": "Lines", "value": f"{lines} lines" },
                { "label": "Recorded", "value": time_ago }
            ]
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
    if len(sys.argv) < 2 or sys.argv[1] == "list":
        query = sys.argv[2] if len(sys.argv) > 2 else ""
        print(json.dumps(list_entries(query)))
    elif sys.argv[1] == "capture":
        if len(sys.argv) > 2:
            capture_text(sys.argv[2])
        else:
            # Read from stdin
            content = sys.stdin.read()
            capture_text(content)
    elif sys.argv[1] == "delete":
        if len(sys.argv) > 2:
            delete_entry(sys.argv[2].replace("clip-", ""))
            print(json.dumps({"status": "deleted"}))
    elif sys.argv[1] == "clear":
        clear_all()
        print(json.dumps({"status": "cleared"}))
