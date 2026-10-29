#!/usr/bin/env python3
"""Index the Omarchy plugin directory and run plugin actions as argv.

Handoff, not a store: listings open in the browser. Install/enable/disable/remove
go through `omarchy plugin …` with a validated id or https git URL. The catalog's
installCommand string is never executed.
"""
from __future__ import annotations

import json
import re
import subprocess
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path
from urllib.parse import urlparse

from path_safety import cache_dir, write_secure_json

CATALOG_URLS = (
    "https://omarchyplugins.com/catalog.json",
    "https://plugins.omarchy.org/catalog.json",
)
CATALOG_CACHE = "plugin-catalog.json"
MERGED_CACHE = "plugins.json"
FRESH_SECONDS = 6 * 60 * 60
MAX_CATALOG_BYTES = 32 * 1024 * 1024
ID_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._-]{0,127}$")
INSTALL_RE = re.compile(
    r"omarchy\s+plugin\s+add\s+(https://\S+\.git)(?:\s+--enable)?\s*"
)


def valid_id(plugin_id: str) -> bool:
    return bool(ID_RE.fullmatch(plugin_id or ""))


def clean_text(value: str, limit: int) -> str:
    text = re.sub(r"[\x00-\x1f]+", " ", value or "")
    text = re.sub(r"\s+", " ", text).strip()
    return text[:limit]


def git_url_ok(url: str) -> bool:
    try:
        parsed = urlparse((url or "").strip())
    except Exception:
        return False
    if parsed.scheme != "https" or parsed.username or parsed.password:
        return False
    if "@" in (parsed.netloc or "") or parsed.query or parsed.fragment:
        return False
    host = (parsed.hostname or "").lower()
    if not host or host in {"localhost", "127.0.0.1", "::1"} or host.endswith(".local"):
        return False
    if re.fullmatch(r"\d+\.\d+\.\d+\.\d+", host):
        return False
    path = parsed.path or ""
    if not path.endswith(".git") or ".." in path or "\\" in path:
        return False
    return True


def https_page_ok(url: str) -> bool:
    try:
        parsed = urlparse((url or "").strip())
    except Exception:
        return False
    if parsed.scheme != "https" or parsed.username or parsed.password:
        return False
    if "@" in (parsed.netloc or "") or not parsed.hostname:
        return False
    host = parsed.hostname.lower()
    if host in {"localhost", "127.0.0.1", "::1"} or re.fullmatch(r"\d+\.\d+\.\d+\.\d+", host):
        return False
    return True


def extract_git_url(install_command: str) -> str:
    match = INSTALL_RE.fullmatch((install_command or "").strip())
    if not match:
        return ""
    url = match.group(1)
    return url if git_url_ok(url) else ""


def _cache_path(name: str) -> Path:
    return cache_dir() / name


def list_installed() -> list[dict]:
    try:
        proc = subprocess.run(
            ["omarchy", "plugin", "list", "--json"],
            capture_output=True,
            text=True,
            timeout=20,
        )
        data = json.loads(proc.stdout or "[]")
    except Exception:
        return []
    if not isinstance(data, list):
        return []
    out = []
    for row in data:
        if not isinstance(row, dict):
            continue
        plugin_id = str(row.get("id") or "")
        if not valid_id(plugin_id):
            continue
        out.append(
            {
                "id": plugin_id,
                "name": clean_text(str(row.get("name") or plugin_id), 128),
                "enabled": bool(row.get("enabled")),
                "firstParty": bool(row.get("firstParty")),
                "canDisable": bool(row.get("canDisable", True)),
                "kinds": row.get("kinds") if isinstance(row.get("kinds"), list) else [],
            }
        )
    return out


def slim_catalog(payload: dict) -> list[dict]:
    plugins = payload.get("plugins") if isinstance(payload, dict) else None
    if not isinstance(plugins, list):
        return []
    out = []
    seen = set()
    for row in plugins:
        if not isinstance(row, dict):
            continue
        plugin_id = str(row.get("id") or "")
        if not valid_id(plugin_id) or plugin_id in seen:
            continue
        seen.add(plugin_id)
        repo = str(row.get("repo") or "")
        if not https_page_ok(repo):
            repo = ""
        tags = row.get("tags") if isinstance(row.get("tags"), list) else []
        tag_text = " ".join(clean_text(str(t), 32) for t in tags[:6] if str(t).strip())
        out.append(
            {
                "id": plugin_id,
                "title": clean_text(str(row.get("name") or plugin_id), 128),
                "description": clean_text(str(row.get("description") or ""), 240),
                "category": clean_text(str(row.get("category") or ""), 48),
                "author": clean_text(str(row.get("author") or ""), 80),
                "kind": clean_text(str(row.get("kind") or ""), 48),
                "version": clean_text(str(row.get("version") or ""), 32),
                "tags": tag_text,
                "repo": repo,
                "git": extract_git_url(str(row.get("installCommand") or "")),
            }
        )
    return out


def load_catalog() -> tuple[list[dict], float]:
    path = _cache_path(CATALOG_CACHE)
    if not path.exists():
        return [], 0.0
    try:
        with open(path, encoding="utf-8") as handle:
            data = json.load(handle)
        entries = data.get("entries") if isinstance(data, dict) else None
        fetched = float(data.get("fetched_at") or 0) if isinstance(data, dict) else 0.0
        if not isinstance(entries, list):
            return [], 0.0
        return [e for e in entries if isinstance(e, dict) and valid_id(str(e.get("id") or ""))], fetched
    except Exception:
        return [], 0.0


def save_catalog(entries: list[dict], fetched_at: float) -> None:
    write_secure_json(_cache_path(CATALOG_CACHE), {"fetched_at": fetched_at, "entries": entries})


def fetch_catalog() -> list[dict]:
    last_error = "catalog fetch failed"
    for url in CATALOG_URLS:
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "omnicast"})
            with urllib.request.urlopen(req, timeout=25) as resp:
                raw = resp.read(MAX_CATALOG_BYTES + 1)
            if len(raw) > MAX_CATALOG_BYTES:
                last_error = "catalog too large"
                continue
            payload = json.loads(raw.decode("utf-8"))
            entries = slim_catalog(payload)
            if entries:
                return entries
            last_error = "catalog was empty"
        except (urllib.error.URLError, TimeoutError, json.JSONDecodeError, OSError) as exc:
            last_error = str(exc)[:160]
            continue
    raise RuntimeError(last_error)


def merge(entries: list[dict], installed: list[dict]) -> list[dict]:
    by_id: dict[str, dict] = {}
    for entry in entries:
        plugin_id = str(entry.get("id") or "")
        if not valid_id(plugin_id):
            continue
        git = str(entry.get("git") or "")
        if git and not git_url_ok(git):
            git = ""
        repo = str(entry.get("repo") or "")
        if repo and not https_page_ok(repo):
            repo = ""
        by_id[plugin_id] = {
            "id": plugin_id,
            "title": clean_text(str(entry.get("title") or plugin_id), 128),
            "subtitle": clean_text(str(entry.get("description") or entry.get("subtitle") or ""), 180),
            "description": clean_text(str(entry.get("description") or ""), 240),
            "category": clean_text(str(entry.get("category") or ""), 48),
            "author": clean_text(str(entry.get("author") or ""), 80),
            "kind": clean_text(str(entry.get("kind") or ""), 48),
            "version": clean_text(str(entry.get("version") or ""), 32),
            "tags": clean_text(str(entry.get("tags") or ""), 120),
            "repo": repo,
            "installable": bool(git),
            "installed": False,
            "enabled": False,
            "firstParty": plugin_id.startswith("omarchy."),
            "canDisable": True,
        }
    for row in installed:
        plugin_id = row["id"]
        current = by_id.get(plugin_id)
        if current is None:
            kinds = ", ".join(str(k) for k in row.get("kinds") or [])
            current = {
                "id": plugin_id,
                "title": row.get("name") or plugin_id,
                "subtitle": "Installed Omarchy plugin",
                "description": "Installed Omarchy plugin",
                "category": "",
                "author": "",
                "kind": clean_text(kinds, 48),
                "version": "",
                "tags": "",
                "repo": "",
                "installable": False,
                "installed": True,
                "enabled": row["enabled"],
                "firstParty": row["firstParty"],
                "canDisable": row["canDisable"],
            }
            by_id[plugin_id] = current
        else:
            current["installed"] = True
            current["enabled"] = row["enabled"]
            current["firstParty"] = row["firstParty"]
            current["canDisable"] = row["canDisable"]
    return list(by_id.values())


def write_merged(plugins: list[dict], fetched_at: float, stale: bool) -> Path:
    path = _cache_path(MERGED_CACHE)
    write_secure_json(
        path,
        {"fetched_at": fetched_at, "stale": stale, "plugins": plugins},
    )
    return path


def build(refresh: bool) -> dict:
    installed = list_installed()
    entries, fetched_at = load_catalog()
    stale = (not entries) or (time.time() - fetched_at > FRESH_SECONDS)
    error = ""
    if refresh:
        try:
            entries = fetch_catalog()
            fetched_at = time.time()
            save_catalog(entries, fetched_at)
            stale = False
        except Exception as exc:
            error = clean_text(str(exc), 180)
            stale = True
    plugins = merge(entries, installed)
    path = write_merged(plugins, fetched_at, stale)
    installed_count = sum(1 for p in plugins if p.get("installed"))
    return {
        "ok": True,
        "count": len(plugins),
        "installed": installed_count,
        "stale": stale,
        "refreshed": bool(refresh and not error),
        "error": error,
        "path": str(path),
    }


def _installed_row(plugin_id: str) -> dict | None:
    for row in list_installed():
        if row["id"] == plugin_id:
            return row
    return None


def _git_for(plugin_id: str) -> str:
    entries, _fetched = load_catalog()
    for entry in entries:
        if str(entry.get("id") or "") == plugin_id:
            url = str(entry.get("git") or "")
            return url if git_url_ok(url) else ""
    return ""


def _run(argv: list[str], timeout: int) -> subprocess.CompletedProcess[str]:
    return subprocess.run(argv, capture_output=True, text=True, timeout=timeout)


def run_op(op: str, plugin_id: str) -> dict:
    if op not in {"install", "enable", "disable", "remove"}:
        return {"ok": False, "op": op, "id": plugin_id, "error": "unknown action"}
    if not valid_id(plugin_id):
        return {"ok": False, "op": op, "id": "", "error": "invalid plugin id"}
    row = _installed_row(plugin_id)
    try:
        if op == "install":
            if row:
                return {"ok": False, "op": op, "id": plugin_id, "error": "already installed"}
            url = _git_for(plugin_id)
            if not url:
                return {
                    "ok": False,
                    "op": op,
                    "id": plugin_id,
                    "error": "no installable git URL; open the listing",
                }
            proc = _run(["omarchy", "plugin", "add", url, "--enable", "--yes"], 180)
            message = f"Installed {plugin_id}"
        elif op == "enable":
            if not row:
                return {"ok": False, "op": op, "id": plugin_id, "error": "not installed"}
            proc = _run(["omarchy", "plugin", "enable", plugin_id], 30)
            message = f"Enabled {plugin_id}"
        elif op == "disable":
            if not row:
                return {"ok": False, "op": op, "id": plugin_id, "error": "not installed"}
            if not row["canDisable"]:
                return {"ok": False, "op": op, "id": plugin_id, "error": "this plugin cannot be disabled"}
            proc = _run(["omarchy", "plugin", "disable", plugin_id], 30)
            message = f"Disabled {plugin_id}"
        else:
            if not row:
                return {"ok": False, "op": op, "id": plugin_id, "error": "not installed"}
            if row["firstParty"] or not row["canDisable"]:
                return {"ok": False, "op": op, "id": plugin_id, "error": "refusing to remove this plugin"}
            proc = _run(["omarchy", "plugin", "remove", plugin_id, "--yes"], 60)
            message = f"Removed {plugin_id}"
    except FileNotFoundError:
        return {"ok": False, "op": op, "id": plugin_id, "error": "omarchy is not installed"}
    except subprocess.TimeoutExpired:
        return {"ok": False, "op": op, "id": plugin_id, "error": "omarchy plugin timed out"}
    if proc.returncode != 0:
        detail = clean_text(proc.stderr or proc.stdout or "omarchy plugin failed", 180)
        return {"ok": False, "op": op, "id": plugin_id, "error": detail or "omarchy plugin failed"}
    return {"ok": True, "op": op, "id": plugin_id, "message": message}


def main() -> int:
    cmd = sys.argv[1] if len(sys.argv) > 1 else "scan"
    if cmd in {"scan", "refresh"}:
        print(json.dumps(build(refresh=cmd == "refresh")))
        return 0
    if cmd == "op-json":
        line = sys.stdin.readline()
        try:
            data = json.loads(line or "{}")
        except json.JSONDecodeError:
            print(json.dumps({"ok": False, "error": "invalid json"}))
            return 0
        if not isinstance(data, dict):
            print(json.dumps({"ok": False, "error": "invalid json"}))
            return 0
        print(json.dumps(run_op(str(data.get("op") or ""), str(data.get("id") or ""))))
        return 0
    print(json.dumps({"ok": False, "error": "usage: scan|refresh|op-json"}))
    return 1


if __name__ == "__main__":
    sys.exit(main())
