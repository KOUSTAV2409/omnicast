#!/usr/bin/env python3
import os
import sys
import json
import re
import time
from pathlib import Path

STATE_DIR = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")) / "omarchy"
HISTORY_FILE = STATE_DIR / "clipboard-history.json"
CONFIG_DIR = Path.home() / ".config/omnicast"
PINNED_FILE = CONFIG_DIR / "pinned_clips.json"

def get_pinned():
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    if PINNED_FILE.exists():
        try:
            with open(PINNED_FILE, "r") as f:
                return json.load(f)
        except:
            return []
    return []

def save_pinned(pinned_list):
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    with open(PINNED_FILE, "w") as f:
        json.dump(pinned_list, f, indent=2)

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
    text_sample = text[:300].strip()
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
    if "SELECT " in text_sample.upper() or "INSERT INTO" in text_sample.upper():
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
    if lang or "\n" in text or (len(text) > 100 and ("=" in text or "(" in text)):
        return "code", lang or "code", ""
        
    return "text", "text", "📄"

def read_omarchy_history(query="", filter_type="all", limit=120):
    if not HISTORY_FILE.exists():
        return []
        
    try:
        with open(HISTORY_FILE, "r", encoding="utf-8", errors="ignore") as f:
            raw_entries = json.load(f)
    except Exception as e:
        return []
        
    pinned_keys = set(get_pinned())
    results = []
    
    # Process newest entries up to limit
    for idx, entry in enumerate(raw_entries[:limit]):
        etype = entry.get("type", "text")
        entry_key = f"image:{entry.get('path')}" if etype == "image" else f"text:{entry.get('text', '')}"
        is_pinned = entry_key in pinned_keys
        
        if filter_type == "pinned" and not is_pinned:
            continue
            
        if etype == "image":
            img_path = entry.get("path", "")
            if not os.path.exists(img_path):
                continue
                
            captured_at = entry.get("capturedAt", "Recent")
            fsize = os.path.getsize(img_path) if os.path.exists(img_path) else 0
            
            if filter_type not in ["all", "pinned", "image"]:
                continue
                
            if query and query.strip():
                q = query.strip().lower()
                if q not in "image" and q not in "screenshot":
                    continue
                    
            results.append({
                "id": f"omarchy-clip-{idx}",
                "key": entry_key,
                "historyIndex": idx,
                "title": f"Screenshot / Image",
                "subtitle": f"{captured_at} • PNG • {fsize // 1024} KB",
                "icon": "📌" if is_pinned else "🖼️",
                "badge": ("📌 " if is_pinned else "") + "Image",
                "contentType": "image",
                "content": "",
                "imagePath": img_path,
                "mime": entry.get("mime") or "image/png",
                "image": f"file://{img_path}",
                "markdown": f"### Image Preview\n\n- **File Size:** `{fsize // 1024} KB`\n- **Captured:** `{captured_at}`\n\nPress **↵** to paste image into active application.",
                "color": "",
                "isPinned": is_pinned,
                "metadata": [
                    { "label": "Type", "value": "PNG Image" },
                    { "label": "File Size", "value": f"{fsize // 1024} KB" },
                    { "label": "Status", "value": "📌 Pinned" if is_pinned else "Recent" },
                    { "label": "Captured", "value": captured_at }
                ]
            })
            
        else: # text
            text = entry.get("text", "")
            if not text:
                continue
                
            ctype, stype, icon = detect_content_type(text)
            
            if filter_type != "all" and filter_type != "pinned" and filter_type != ctype:
                continue
                
            if query and query.strip():
                if query.strip().lower() not in text.lower():
                    continue
                    
            lines = text.split("\n")
            line_count = len(lines)
            char_count = len(text)
            word_count = len(text.split())
            
            first_line = lines[0][:75]
            preview_title = first_line + ("..." if len(lines[0]) > 75 or line_count > 1 else "")
            
            metadata = []
            markdown = ""
            
            if ctype == "color":
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
                    { "label": "Status", "value": "📌 Pinned" if is_pinned else "Recent" }
                ]
            elif ctype == "url":
                clean_url = text.strip()
                domain_match = re.search(r'https?:\/\/([^\/\s]+)', clean_url)
                domain = domain_match.group(1) if domain_match else clean_url
                markdown = f"### Web Link\n\n[{clean_url}]({clean_url})\n\n- **Domain:** `{domain}`\n\nPress **↵** to copy, **Ctrl+O** to open in browser."
                metadata = [
                    { "label": "Type", "value": "Web Link" },
                    { "label": "Domain", "value": domain },
                    { "label": "Length", "value": f"{char_count} chars" },
                    { "label": "Status", "value": "📌 Pinned" if is_pinned else "Recent" }
                ]
            elif ctype == "code":
                lang = stype if stype != "code" else ""
                markdown = f"```{lang}\n{text[:2000]}\n```"
                metadata = [
                    { "label": "Type", "value": f"Code ({lang.upper() or 'Snippet'})" },
                    { "label": "Lines", "value": f"{line_count} lines" },
                    { "label": "Characters", "value": f"{char_count} chars" },
                    { "label": "Words", "value": f"{word_count} words" },
                    { "label": "Status", "value": "📌 Pinned" if is_pinned else "Recent" }
                ]
            else:
                markdown = f"{text[:2000]}"
                metadata = [
                    { "label": "Type", "value": "Plain Text" },
                    { "label": "Characters", "value": f"{char_count} chars" },
                    { "label": "Words", "value": f"{word_count} words" },
                    { "label": "Lines", "value": f"{line_count} lines" },
                    { "label": "Status", "value": "📌 Pinned" if is_pinned else "Recent" }
                ]
                
            results.append({
                "id": f"omarchy-clip-{idx}",
                "key": entry_key,
                "historyIndex": idx,
                "title": preview_title,
                "subtitle": f"{ctype.capitalize()} • {char_count} chars",
                "icon": "📌" if is_pinned else ("🎨" if ctype == "color" else ("🌐" if ctype == "url" else ("" if ctype == "code" else "📄"))),
                "badge": ("📌 " if is_pinned else "") + ctype.capitalize(),
                "contentType": ctype,
                "content": text,
                "imagePath": "",
                "image": "",
                "markdown": markdown,
                "color": text if ctype == "color" else "",
                "isPinned": is_pinned,
                "metadata": metadata
            })
            
    sorted_results = sorted(results, key=lambda x: not x["isPinned"])
    return sorted_results

def toggle_pin(key):
    pinned = get_pinned()
    if key in pinned:
        pinned.remove(key)
    else:
        pinned.append(key)
    save_pinned(pinned)

def remove_entry(key):
    if not HISTORY_FILE.exists():
        return
    try:
        with open(HISTORY_FILE, "r") as f:
            entries = json.load(f)
        filtered = []
        for e in entries:
            k = f"image:{e.get('path')}" if e.get("type") == "image" else f"text:{e.get('text', '')}"
            if k != key:
                filtered.append(e)
        with open(HISTORY_FILE, "w") as f:
            json.dump(filtered, f, indent=2)
    except:
        pass

if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "list"
    
    if cmd == "list":
        query = sys.argv[2] if len(sys.argv) > 2 else ""
        ftype = sys.argv[3] if len(sys.argv) > 3 else "all"
        print(json.dumps(read_omarchy_history(query, ftype)))
    elif cmd == "pin":
        if len(sys.argv) > 2:
            toggle_pin(sys.argv[2])
            print(json.dumps({"status": "toggled"}))
    elif cmd == "delete":
        if len(sys.argv) > 2:
            remove_entry(sys.argv[2])
            print(json.dumps({"status": "deleted"}))
