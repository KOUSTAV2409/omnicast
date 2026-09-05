#!/usr/bin/env python3
import json
import os
import subprocess
import sys
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
    "wifi": "📶",
}

CACHE_DIR = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "omnicast"
CACHE_FILE = CACHE_DIR / "omarchy-commands.json"


def get_omarchy_commands():
    try:
        proc = subprocess.run(
            ["omarchy", "commands", "--json"],
            capture_output=True,
            text=True,
            timeout=30,
        )
        data = json.loads(proc.stdout or "{}")
        raw_cmds = data.get("commands", [])
    except Exception:
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
        title = (
            route.replace("omarchy ", "Omarchy: ").title()
            if not name
            else f"Omarchy: {group.title()} {name.title()}"
        )

        results.append(
            {
                "id": f"omarchy-cmd-{route.replace(' ', '-')}",
                "title": title,
                "subtitle": summary or f"Run `{route}`",
                "icon": icon,
                "category": f"Omarchy {group.title()}",
                "badge": "Omarchy",
                "route": route,
                "keyword": route,
                "args": args,
                "exec": f"omarchy {group} {name}".strip(),
            }
        )

    return results


def write_cache(cmds):
    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    CACHE_FILE.write_text(json.dumps(cmds, ensure_ascii=False), encoding="utf-8")
    return CACHE_FILE


if __name__ == "__main__":
    # Quickshell StdioCollector drops large stdout (~180KB): write a cache file
    # and print only a tiny status line for the QML Process to read.
    cmds = get_omarchy_commands()
    path = write_cache(cmds)
    print(json.dumps({"ok": True, "count": len(cmds), "path": str(path)}))
