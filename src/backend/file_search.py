#!/usr/bin/env python3
"""Omnicast file search: fd preferred, plocate fallback.

Usage:
  python3 file_search.py <query> [--limit N]

Prints JSON list of hits under $HOME (files and directories).
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path


EXCLUDE_GLOBS = [
    ".git",
    "node_modules",
    ".cache",
    ".local/share/Trash",
    ".local/share/flatpak",
    ".npm",
    ".cargo/registry",
    ".rustup",
    "target/debug",
    "target/release",
    "__pycache__",
    ".venv",
    "venv",
    "myenv",
    "site-packages",
    "dist-packages",
    ".tox",
    ".mypy_cache",
    ".pytest_cache",
]


def home() -> Path:
    return Path.home().resolve()


def rel_home(path: Path) -> str:
    try:
        return "~/" + str(path.resolve().relative_to(home()))
    except Exception:
        return str(path)


def icon_for(path: Path, is_dir: bool) -> str:
    if is_dir:
        return "󰉋"
    name = path.name.lower()
    if name.endswith((".png", ".jpg", ".jpeg", ".gif", ".webp", ".svg")):
        return "󰈟"
    if name.endswith((".mp4", ".mkv", ".webm", ".mov")):
        return "󰈫"
    if name.endswith((".mp3", ".flac", ".wav", ".ogg")):
        return "󰈣"
    if name.endswith((".pdf",)):
        return "󰈦"
    if name.endswith((".md", ".txt", ".rst")):
        return "󰈙"
    if name.endswith((".py", ".js", ".ts", ".go", ".rs", ".qml", ".lua", ".sh")):
        return "󰈮"
    return "󰈔"


def rank_key(query: str, path: Path) -> tuple:
    q = query.lower()
    base = path.name.lower()
    full = str(path).lower()
    if base == q:
        tier = 0
    elif base.startswith(q):
        tier = 1
    elif q in base:
        tier = 2
    elif q in full:
        tier = 3
    else:
        tier = 9
    return (tier, len(base), len(full), base)


def search_fd(query: str, limit: int) -> list[Path] | None:
    fd = shutil.which("fd") or shutil.which("fdfind")
    if not fd:
        return None
    cmd = [
        fd,
        "-i",
        "--color=never",
        "--max-results",
        str(max(limit * 3, limit)),
        "--exclude",
        "{" + ",".join(EXCLUDE_GLOBS) + "}",
        query,
        str(home()),
    ]
    # Older fd may not like brace exclude — fall back to repeated --exclude
    try:
        out = subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL, timeout=2.5)
    except Exception:
        cmd = [fd, "-i", "--color=never", "--max-results", str(max(limit * 3, limit))]
        for g in EXCLUDE_GLOBS:
            cmd.extend(["--exclude", g])
        cmd.extend([query, str(home())])
        try:
            out = subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL, timeout=2.5)
        except Exception:
            return []
    paths = []
    for line in out.splitlines():
        line = line.strip()
        if not line:
            continue
        p = Path(line)
        if p.exists():
            paths.append(p)
    return paths


def search_plocate(query: str, limit: int) -> list[Path]:
    loc = shutil.which("plocate") or shutil.which("locate")
    if not loc:
        return []
    home_s = str(home())
    try:
        out = subprocess.check_output(
            [loc, "-i", "-l", str(max(limit * 5, 50)), query],
            text=True,
            stderr=subprocess.DEVNULL,
            timeout=2.5,
        )
    except Exception:
        return []
    paths = []
    for line in out.splitlines():
        line = line.strip()
        if not line.startswith(home_s):
            continue
        # Skip noisy cache paths
        low = line.lower()
        if any(
            x in low
            for x in (
                "/.cache/",
                "/node_modules/",
                "/.git/",
                "/trash/",
                "/site-packages/",
                "/dist-packages/",
                "/.venv/",
                "/venv/",
                "/myenv/",
            )
        ):
            continue
        p = Path(line)
        if p.exists():
            paths.append(p)
    return paths


def path_query_hits(query: str) -> list[Path]:
    """If query looks like a path, resolve it directly."""
    q = query.strip()
    if not q:
        return []
    expanded = Path(os.path.expanduser(q))
    hits = []
    if expanded.exists():
        hits.append(expanded)
    return hits


def search(query: str, limit: int = 16) -> list[dict]:
    q = (query or "").strip()
    if len(q) < 2:
        return []

    paths = path_query_hits(q)
    found = search_fd(q, limit)
    if found is None:
        found = search_plocate(q, limit)
    paths.extend(found or [])

    # Dedupe + rank
    seen = set()
    uniq = []
    for p in paths:
        try:
            key = str(p.resolve())
        except Exception:
            key = str(p)
        if key in seen:
            continue
        seen.add(key)
        uniq.append(p)

    uniq.sort(key=lambda p: rank_key(q, p))
    uniq = uniq[:limit]

    out = []
    for p in uniq:
        is_dir = p.is_dir()
        title = p.name or str(p)
        try:
            resolved = str(p.resolve())
        except Exception:
            resolved = str(p)
        hid = hashlib.sha1(resolved.encode()).hexdigest()[:12]
        out.append(
            {
                "id": f"file-{hid}",
                "title": title + ("/" if is_dir else ""),
                "subtitle": rel_home(p),
                "path": resolved,
                "is_dir": is_dir,
                "icon": icon_for(p, is_dir),
                "category": "Files",
                "badge": "Dir" if is_dir else "File",
            }
        )
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("query")
    ap.add_argument("--limit", type=int, default=16)
    args = ap.parse_args()
    hits = search(args.query, args.limit)
    cache_dir = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "omnicast"
    cache_dir.mkdir(parents=True, exist_ok=True)
    cache_file = cache_dir / "file-search.json"
    payload = {"query": args.query.strip(), "hits": hits}
    cache_file.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")
    # Tiny stdout: Quickshell StdioCollector can drop large buffers
    print(json.dumps({"ok": True, "count": len(hits), "path": str(cache_file), "query": args.query.strip()}))
    return 0


if __name__ == "__main__":
    sys.exit(main())
