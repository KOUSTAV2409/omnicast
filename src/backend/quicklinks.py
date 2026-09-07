#!/usr/bin/env python3
import json
import sys
import subprocess
import urllib.parse
from pathlib import Path

from path_safety import write_secure_json

CONFIG = Path.home() / ".config/omnicast/quicklinks.json"

DEFAULTS = [
    {
        "id": "ql-google",
        "title": "Google Search",
        "subtitle": "Search the web",
        "icon": "🔍",
        "url": "https://www.google.com/search?q={argument}",
        "keyword": "g",
    },
    {
        "id": "ql-github",
        "title": "GitHub",
        "subtitle": "Open GitHub",
        "icon": "🐙",
        "url": "https://github.com/{argument}",
        "keyword": "gh",
    },
    {
        "id": "ql-youtube",
        "title": "YouTube Search",
        "subtitle": "Search YouTube",
        "icon": "▶️",
        "url": "https://www.youtube.com/results?search_query={argument}",
        "keyword": "yt",
    },
]


def _ensure_config_perms() -> None:
    CONFIG.parent.mkdir(parents=True, exist_ok=True)
    try:
        import os

        os.chmod(CONFIG.parent, 0o700)
    except Exception:
        pass


def load():
    _ensure_config_perms()
    if not CONFIG.exists():
        write_secure_json(CONFIG, DEFAULTS)
        return list(DEFAULTS)
    try:
        with open(CONFIG) as f:
            return json.load(f)
    except Exception:
        return list(DEFAULTS)


def resolve(url: str, argument: str = "") -> str:
    clip = ""
    try:
        clip = subprocess.check_output(
            ["wl-paste", "--no-newline"], text=True, stderr=subprocess.DEVNULL
        )
    except Exception:
        pass
    out = url.replace("{clipboard}", urllib.parse.quote(clip))
    out = out.replace("{argument}", urllib.parse.quote(argument or ""))
    out = out.replace("{query}", urllib.parse.quote(argument or ""))
    return out


def url_allowed(url: str) -> bool:
    low = (url or "").strip().lower()
    return low.startswith("https://") or low.startswith("http://") or low.startswith("mailto:")


def list_links():
    results = []
    for q in load():
        needs_arg = "{argument}" in q.get("url", "") or "{query}" in q.get("url", "")
        results.append(
            {
                "id": q.get("id"),
                "title": q.get("title"),
                "subtitle": q.get("subtitle") or q.get("url"),
                "icon": q.get("icon") or "🔗",
                "badge": "Link",
                "category": "Quicklinks",
                "url": q.get("url"),
                "keyword": q.get("keyword") or "",
                "needsArgument": needs_arg,
                "primaryActionTitle": "Open Link",
                "markdown": f"### {q.get('title')}\n\n`{q.get('url')}`\n\nKeyword: `{q.get('keyword', '')}`",
            }
        )
    return results


def open_link(link_id: str, argument: str = ""):
    for q in load():
        if q.get("id") == link_id:
            url = resolve(q.get("url", ""), argument)
            if not url_allowed(url):
                print(json.dumps({"ok": False, "error": "blocked scheme (http/https/mailto only)"}))
                return
            subprocess.Popen(["xdg-open", url])
            print(json.dumps({"ok": True, "url": url}))
            return
    print(json.dumps({"ok": False, "error": "not found"}))


if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] == "list":
        from path_safety import cache_dir

        results = list_links()
        cache_file = cache_dir() / "quicklinks.json"
        write_secure_json(cache_file, results)
        print(json.dumps({"ok": True, "count": len(results), "path": str(cache_file)}))
    elif sys.argv[1] == "open" and len(sys.argv) > 2:
        open_link(sys.argv[2], sys.argv[3] if len(sys.argv) > 3 else "")
    else:
        sys.exit(1)
