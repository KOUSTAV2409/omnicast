#!/usr/bin/env python3
"""Frecency, favorites, and aliases for Omnicast root search."""
import json
import sys
import time
from pathlib import Path

DATA_DIR = Path.home() / ".local/share/omnicast"
DATA_FILE = DATA_DIR / "ranking.json"

DEFAULT = {
    "favorites": [],
    "aliases": {},
    "scores": {},
    "recent": [],
}


def load():
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    if not DATA_FILE.exists():
        return json.loads(json.dumps(DEFAULT))
    try:
        with open(DATA_FILE) as f:
            data = json.load(f)
        for k, v in DEFAULT.items():
            data.setdefault(k, json.loads(json.dumps(v)))
        return data
    except Exception:
        return json.loads(json.dumps(DEFAULT))


def save(data):
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    with open(DATA_FILE, "w") as f:
        json.dump(data, f, indent=2)


def bump(item_id: str):
    data = load()
    now = time.time()
    entry = data["scores"].get(item_id, {"count": 0, "last": 0, "score": 0})
    entry["count"] = int(entry.get("count", 0)) + 1
    entry["last"] = now
    entry["score"] = entry["count"] * 10 + min(entry["count"], 50)
    data["scores"][item_id] = entry
    recent = data.setdefault("recent", [])
    if item_id in recent:
        recent.remove(item_id)
    recent.insert(0, item_id)
    data["recent"] = recent[:40]
    save(data)
    print(json.dumps({"ok": True, "entry": entry}))


def toggle_favorite(item_id: str):
    data = load()
    favs = data.setdefault("favorites", [])
    if item_id in favs:
        favs.remove(item_id)
        state = False
    else:
        favs.insert(0, item_id)
        state = True
    save(data)
    print(json.dumps({"ok": True, "favorited": state, "favorites": favs}))


def set_alias(alias: str, item_id: str):
    data = load()
    alias = alias.strip().lower()
    if not alias:
        print(json.dumps({"ok": False, "error": "empty alias"}))
        return
    data.setdefault("aliases", {})[alias] = item_id
    save(data)
    print(json.dumps({"ok": True, "alias": alias, "id": item_id}))


def clear_alias(alias: str):
    data = load()
    data.setdefault("aliases", {}).pop(alias.strip().lower(), None)
    save(data)
    print(json.dumps({"ok": True}))


def dump():
    print(json.dumps(load()))


if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] == "dump":
        dump()
    elif sys.argv[1] == "bump" and len(sys.argv) > 2:
        bump(sys.argv[2])
    elif sys.argv[1] == "favorite" and len(sys.argv) > 2:
        toggle_favorite(sys.argv[2])
    elif sys.argv[1] == "alias" and len(sys.argv) > 3:
        set_alias(sys.argv[2], sys.argv[3])
    elif sys.argv[1] == "unalias" and len(sys.argv) > 2:
        clear_alias(sys.argv[2])
    else:
        print(json.dumps({"error": "usage"}))
        sys.exit(1)
