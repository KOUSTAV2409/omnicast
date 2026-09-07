#!/usr/bin/env python3
"""Omnicast file search: fd / plocate name hits + optional rg content hits.

Usage:
  python3 file_search.py <query> [--limit N] [--scope home|projects|documents|downloads|desktop]
                           [--content|--no-content]

Query prefixes:
  in:projects foo   → scope projects, query foo
  content:bar       → force content search for bar

Security: results are limited to the active scope under $HOME; credential and
session paths are denied (see path_safety.py).
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

from path_safety import (
    SECRET_RG_GLOBS,
    allowed_path,
    cache_dir,
    home,
    is_secret_path,
    is_under,
    write_secure_json,
)


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
    "*.pyc",
    "*.pyo",
    "*.pyd",
    "*.so",
    "*.o",
    "*.a",
    "*.class",
    "*.egg-info",
    ".venv",
    "venv",
    "myenv",
    "site-packages",
    "dist-packages",
    ".tox",
    ".mypy_cache",
    ".pytest_cache",
    # Credential / session trees (fd exclude)
    ".ssh",
    ".gnupg",
    ".password-store",
    ".aws",
    ".azure",
    ".kube",
    ".docker",
    ".mozilla",
    ".thunderbird",
    ".config/gcloud",
    ".config/gh",
    ".config/chromium",
    ".config/google-chrome",
    ".config/BraveSoftware",
    ".config/keepassxc",
    ".config/Bitwarden",
    ".config/1Password",
    ".config/Signal",
    ".config/Element",
    ".local/share/keyrings",
]

NOISE_SUFFIXES = (
    ".pyc",
    ".pyo",
    ".pyd",
    ".so",
    ".o",
    ".a",
    ".class",
    ".dll",
    ".dylib",
    ".exe",
    ".whl",
    ".egg",
)

NOISE_NAME_PARTS = (
    ".cpython-",
    ".pyc.",
    "__pycache__",
)

SCOPE_DIRS = {
    "home": lambda: Path.home(),
    "projects": lambda: Path.home() / "Projects",
    "documents": lambda: Path.home() / "Documents",
    "downloads": lambda: Path.home() / "Downloads",
    "desktop": lambda: Path.home() / "Desktop",
}


def scope_root(name: str) -> Path:
    key = (name or "home").strip().lower()
    factory = SCOPE_DIRS.get(key, SCOPE_DIRS["home"])
    root = factory()
    try:
        root = root.resolve()
    except Exception:
        root = Path(root)
    if not root.exists() or not is_under(root, home()):
        return home()
    return root


def rel_home(path: Path) -> str:
    try:
        return "~/" + str(path.resolve().relative_to(home()))
    except Exception:
        return str(path)


def icon_for(path: Path, is_dir: bool) -> str:
    if is_dir:
        return "󰉋"
    name = path.name.lower()
    if name.endswith((".png", ".jpg", ".jpeg", ".gif", ".webp", ".bmp", ".ico")):
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


def rank_key(query: str, path: Path, content: bool = False) -> tuple:
    q = query.lower()
    base = path.name.lower()
    full = str(path).lower()
    if content:
        tier = 4
    elif base == q:
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


def parse_query(raw: str, default_scope: str) -> tuple[str, str, bool]:
    """Return (query, scope, force_content)."""
    q = (raw or "").strip()
    scope = default_scope
    force_content = False

    m = re.match(r"^in:(\w+)\s+(.+)$", q, re.I)
    if m:
        scope = m.group(1).lower()
        q = m.group(2).strip()

    m = re.match(r"^content:(.+)$", q, re.I)
    if m:
        force_content = True
        q = m.group(1).strip()

    return q, scope, force_content


def is_noise_path(path: Path) -> bool:
    """Drop bytecode / build artifacts that clutter Files results."""
    name = path.name
    low = name.lower()
    full = str(path).lower().replace("\\", "/")
    if any(
        part in full
        for part in (
            "/__pycache__/",
            "/site-packages/",
            "/dist-packages/",
            "/.venv/",
            "/venv/",
            "/myenv/",
            "/node_modules/",
            "/.git/",
            "/.tox/",
            "/.mypy_cache/",
            "/.pytest_cache/",
            "/.cache/",
            ".egg-info/",
        )
    ):
        return True
    if any(low.endswith(suf) for suf in NOISE_SUFFIXES):
        return True
    if any(part in low for part in NOISE_NAME_PARTS):
        return True
    return False


def accept_hit(path: Path, root: Path) -> bool:
    if not path.exists():
        return False
    if is_noise_path(path):
        return False
    if is_secret_path(path):
        return False
    return allowed_path(path, root)


def search_fd(query: str, limit: int, root: Path) -> list[Path] | None:
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
        "--",
        query,
        str(root),
    ]
    try:
        out = subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL, timeout=2.5)
    except Exception:
        cmd = [fd, "-i", "--color=never", "--max-results", str(max(limit * 3, 40))]
        for g in EXCLUDE_GLOBS:
            cmd.extend(["--exclude", g])
        cmd.extend(["--", query, str(root)])
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
        if accept_hit(p, root):
            paths.append(p)
    return paths


def search_plocate(query: str, limit: int, root: Path) -> list[Path]:
    loc = shutil.which("plocate") or shutil.which("locate")
    if not loc:
        return []
    try:
        out = subprocess.check_output(
            [loc, "-i", "-l", str(max(limit * 5, 50)), "--", query],
            text=True,
            stderr=subprocess.DEVNULL,
            timeout=2.5,
        )
    except Exception:
        # Older locate may lack --
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
        if not line:
            continue
        p = Path(line)
        if accept_hit(p, root):
            paths.append(p)
        if len(paths) >= limit * 3:
            break
    return paths


def search_content(query: str, limit: int, root: Path) -> list[Path]:
    """Find files whose contents match query (rg). Never scans secret trees."""
    rg = shutil.which("rg")
    if not rg or len(query) < 2:
        return []
    cmd = [
        rg,
        "-l",
        "-i",
        "--color=never",
        # Do NOT use --hidden: avoids crawling .ssh / .env by default.
        "--glob",
        "!.git/**",
        "--glob",
        "!node_modules/**",
        "--glob",
        "!.cache/**",
        "--glob",
        "!.venv/**",
        "--glob",
        "!venv/**",
        "--glob",
        "!**/site-packages/**",
        "--glob",
        "!**/dist-packages/**",
        "--glob",
        "!target/**",
        "--glob",
        "!**/__pycache__/**",
        "--glob",
        "!*.pyc",
        "--glob",
        "!*.pyo",
    ]
    for g in SECRET_RG_GLOBS:
        cmd.extend(["--glob", g])
    cmd.extend(
        [
            "--max-count",
            "1",
            "-m",
            str(max(limit * 2, 24)),
            "--",
            query,
            str(root),
        ]
    )
    try:
        out = subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL, timeout=3.0)
    except Exception:
        return []
    paths = []
    for line in out.splitlines():
        line = line.strip()
        if not line:
            continue
        p = Path(line)
        if p.is_file() and accept_hit(p, root):
            paths.append(p)
        if len(paths) >= limit:
            break
    return paths


def path_query_hits(query: str, root: Path) -> list[Path]:
    """Exact path / ~ expansion — only if inside scope and not secret."""
    q = query.strip()
    if not q:
        return []
    # Require path-like input so random strings don't hit exists()
    if not (q.startswith("/") or q.startswith("~") or "/" in q):
        return []
    expanded = Path(os.path.expanduser(q))
    if not expanded.exists():
        return []
    if accept_hit(expanded, root):
        return [expanded]
    return []


def hit_dict(p: Path, *, content: bool = False, snippet: str = "") -> dict:
    is_dir = p.is_dir()
    title = p.name or str(p)
    try:
        resolved = str(p.resolve())
    except Exception:
        resolved = str(p)
    hid = hashlib.sha1(resolved.encode()).hexdigest()[:12]
    badge = "Dir" if is_dir else ("Content" if content else "File")
    subtitle = rel_home(p)
    if content and snippet:
        subtitle = snippet + " · " + subtitle
    return {
        "id": f"file-{hid}" + ("-c" if content else ""),
        "title": title + ("/" if is_dir else ""),
        "subtitle": subtitle,
        "path": resolved,
        "is_dir": is_dir,
        "icon": icon_for(p, is_dir),
        "category": "Files",
        "badge": badge,
        "content_match": content,
    }


def search(
    query: str,
    limit: int = 16,
    scope: str = "home",
    content: bool = False,
) -> tuple[list[dict], str, str]:
    q, scope_name, force_content = parse_query(query, scope)
    root = scope_root(scope_name)
    if len(q) < 2:
        return [], q, scope_name

    name_limit = limit if not force_content else max(4, limit // 3)
    content_limit = limit if force_content else max(6, limit // 2)

    paths: list[tuple[Path, bool]] = []  # path, is_content
    for p in path_query_hits(q, root):
        paths.append((p, False))

    if not force_content:
        found = search_fd(q, name_limit, root)
        if found is None:
            found = search_plocate(q, name_limit, root)
        for p in found or []:
            paths.append((p, False))

    # Content search is opt-in only (content:query or --content).
    do_content = force_content or content
    if do_content:
        for p in search_content(q, content_limit, root):
            paths.append((p, True))

    seen: set[str] = set()
    uniq: list[tuple[Path, bool]] = []
    for p, is_c in paths:
        if not accept_hit(p, root):
            continue
        try:
            key = str(p.resolve())
        except Exception:
            key = str(p)
        if key in seen:
            continue
        seen.add(key)
        uniq.append((p, is_c))

    uniq.sort(key=lambda t: rank_key(q, t[0], t[1]))
    uniq = uniq[:limit]

    out = [hit_dict(p, content=is_c) for p, is_c in uniq]
    return out, q, scope_name


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("query")
    ap.add_argument("--limit", type=int, default=16)
    ap.add_argument("--scope", default="home")
    ap.add_argument("--content", dest="content", action="store_true", default=False)
    ap.add_argument("--no-content", dest="content", action="store_false")
    args = ap.parse_args()

    hits, parsed_q, scope_name = search(
        args.query, args.limit, scope=args.scope, content=args.content
    )
    cache_file = cache_dir() / "file-search.json"
    payload = {
        "query": args.query.strip(),
        "parsed_query": parsed_q,
        "scope": scope_name,
        "hits": hits,
    }
    write_secure_json(cache_file, payload)
    print(
        json.dumps(
            {
                "ok": True,
                "count": len(hits),
                "path": str(cache_file),
                "query": args.query.strip(),
                "scope": scope_name,
            }
        )
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
