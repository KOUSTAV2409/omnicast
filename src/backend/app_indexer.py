#!/usr/bin/env python3
import os
import sys
import json
import re
from pathlib import Path

APP_DIRS = [
    Path("/usr/share/applications"),
    Path("/usr/local/share/applications"),
    Path.home() / ".local/share/applications",
    Path("/var/lib/flatpak/exports/share/applications")
]

def clean_exec(exec_str):
    # Remove field codes (%f, %F, %u, %U, %d, %D, %n, %N, %i, %c, %k, %v, %m)
    cleaned = re.sub(r"%[a-zA-Z]", "", exec_str).strip()
    return cleaned

def get_app_icon(name, icon_field):
    # Return a friendly icon or emoji based on app category/name
    n = name.lower()
    if "brave" in n or "chrome" in n or "firefox" in n or "browser" in n:
        return "🌐"
    elif "cursor" in n or "code" in n or "neovim" in n or "editor" in n or "helix" in n:
        return "💻"
    elif "terminal" in n or "ghostty" in n or "alacritty" in n or "foot" in n or "kitty" in n:
        return "👻" if "ghostty" in n else ""
    elif "obsidian" in n or "notes" in n or "write" in n:
        return "💎" if "obsidian" in n else "📝"
    elif "discord" in n or "slack" in n or "telegram" in n or "whatsapp" in n or "signal" in n:
        return "💬"
    elif "spotify" in n or "music" in n or "audio" in n:
        return "🎵"
    elif "files" in n or "nautilus" in n or "thunar" in n:
        return "📁"
    elif "calc" in n:
        return "🔢"
    elif "setting" in n or "control" in n or "config" in n:
        return "⚙️"
    elif "image" in n or "photo" in n or "gimp" in n or "pinta" in n or "imv" in n:
        return "🖼️"
    elif "video" in n or "mpv" in n or "vlc" in n or "kdenlive" in n:
        return "🎬"
    return ""

def index_desktop_apps():
    apps = {}
    
    for adir in APP_DIRS:
        if not adir.exists():
            continue
            
        for dfile in adir.glob("*.desktop"):
            try:
                with open(dfile, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.read()
                    
                # Look inside [Desktop Entry] section
                if "[Desktop Entry]" not in content:
                    continue
                    
                entry_section = content.split("[Desktop Entry]")[1].split("\n[")[0]
                lines = entry_section.split("\n")
                
                app_info = {
                    "desktop_file": dfile.name,
                    "name": "",
                    "exec": "",
                    "icon": "",
                    "comment": "",
                    "nodisplay": False,
                    "terminal": False,
                    "categories": "Applications"
                }
                
                for line in lines:
                    line = line.strip()
                    if not line or line.startswith("#") or "=" not in line:
                        continue
                    key, val = line.split("=", 1)
                    key = key.strip()
                    val = val.strip()
                    
                    if key == "Name" and not app_info["name"]:
                        app_info["name"] = val
                    elif key == "Exec" and not app_info["exec"]:
                        app_info["exec"] = val
                    elif key == "Icon" and not app_info["icon"]:
                        app_info["icon"] = val
                    elif key == "Comment" and not app_info["comment"]:
                        app_info["comment"] = val
                    elif key == "GenericName" and not app_info["comment"]:
                        app_info["comment"] = val
                    elif key == "NoDisplay" and val.lower() == "true":
                        app_info["nodisplay"] = True
                    elif key == "Terminal" and val.lower() == "true":
                        app_info["terminal"] = True
                    elif key == "Categories":
                        app_info["categories"] = val.split(";")[0] if val else "Applications"
                        
                if app_info["name"] and app_info["exec"] and not app_info["nodisplay"]:
                    clean_cmd = clean_exec(app_info["exec"])
                    if app_info["terminal"]:
                        clean_cmd = f"ghostty -e {clean_cmd}"
                        
                    app_id = f"app-{dfile.stem.lower()}"
                    # Avoid duplicates (prefer user local desktop entries)
                    if app_id not in apps or str(dfile).startswith(str(Path.home())):
                        apps[app_id] = {
                            "id": app_id,
                            "title": app_info["name"],
                            "subtitle": app_info["comment"] or f"Application • {app_info['categories']}",
                            "icon": get_app_icon(app_info["name"], app_info["icon"]),
                            "category": "Applications",
                            "badge": "App",
                            "exec": clean_cmd,
                            "desktop_path": str(dfile)
                        }
            except Exception as e:
                pass
                
    # Sort alphabetically by title
    sorted_apps = sorted(list(apps.values()), key=lambda x: x["title"].lower())
    return sorted_apps

if __name__ == "__main__":
    import os
    apps = index_desktop_apps()
    cache_dir = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "omnicast"
    cache_dir.mkdir(parents=True, exist_ok=True)
    cache_file = cache_dir / "desktop-apps.json"
    cache_file.write_text(json.dumps(apps, ensure_ascii=False), encoding="utf-8")
    # Tiny status only — large stdout is dropped by Quickshell StdioCollector
    print(json.dumps({"ok": True, "count": len(apps), "path": str(cache_file)}))
