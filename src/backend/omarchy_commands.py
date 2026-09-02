#!/usr/bin/env python3
import os
import sys
import json
import subprocess
from pathlib import Path

CATEGORY_ICONS = {
    "agent": "🤖",
    "audio": "🔊",
    "bar": "📊",
    "battery": "🔋",
    "bluetooth": "",
    "brightness": "☀️",
    "capture": "📸",
    "clipboard": "📋",
    "config": "⚙️",
    "debug": "🩺",
    "default": "⭐",
    "disk": "💾",
    "display": "🖥️",
    "font": "🔤",
    "games": "🎮",
    "hw": "🔧",
    "hyprland": "🪟",
    "launch": "🚀",
    "menu": "☰",
    "network": "🌐",
    "notification": "🔔",
    "osd": "🎛️",
    "pkg": "📦",
    "plugin": "🧩",
    "power": "⚡",
    "reminder": "⏰",
    "restart": "🔄",
    "screensaver": "🌌",
    "system": "💻",
    "tailscale": "🔒",
    "theme": "🎨",
    "toggle": "🔘",
    "transcode": "🎬",
    "tui": "",
    "update": "⬆️",
    "version": "ℹ️",
    "voxtype": "🎙️",
    "weather": "🌤️",
    "webapp": "🌐",
    "wifi": "📶"
}

def get_omarchy_commands():
    try:
        proc = subprocess.run(["omarchy", "commands", "--json"], capture_output=True, text=True)
        data = json.loads(proc.stdout)
        raw_cmds = data.get("commands", [])
    except Exception as e:
        return []
        
    results = []
    for cmd in raw_cmds:
        if cmd.get("hidden"):
            continue
            
        group = cmd.get("group", "system")
        name = cmd.get("name", "")
        summary = cmd.get("summary", "")
        route = cmd.get("route", "")
        args = cmd.get("args", "")
        
        icon = CATEGORY_ICONS.get(group, "⚙️")
        title = route.replace("omarchy ", "Omarchy: ").title() if not name else f"Omarchy: {group.title()} {name.title()}"
        
        results.append({
            "id": f"omarchy-cmd-{route.replace(' ', '-')}",
            "title": title,
            "subtitle": summary or f"Run `{route}`",
            "icon": icon,
            "category": f"Omarchy {group.title()}",
            "badge": "Omarchy",
            "route": route,
            "args": args,
            "exec": f"omarchy {group} {name}".strip()
        })
        
    return results

if __name__ == "__main__":
    cmds = get_omarchy_commands()
    print(json.dumps(cmds))
