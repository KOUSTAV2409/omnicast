#!/usr/bin/env python3
import json
import uuid
import datetime
import shutil
import subprocess
import sys
import time
from pathlib import Path

SNIPPETS_FILE = Path.home() / ".config/omnicast/snippets.json"
SETTINGS_FILE = Path.home() / ".config/omnicast/snippetd.json"

DEFAULT_SETTINGS = {
    "delay_ms": 150,
    "backend": "auto",  # auto | wtype | ydotool
}

DEFAULT_SNIPPETS = [
    {
        "id": "snip-shrug",
        "keyword": ":shrug",
        "title": "¯\\_(ツ)_/¯ (Shrug)",
        "snippet": "¯\\_(ツ)_/¯",
        "category": "Emojis",
    },
    {
        "id": "snip-date",
        "keyword": ":date",
        "title": "Current Date (YYYY-MM-DD)",
        "snippet": "{date}",
        "category": "Dynamic",
    },
    {
        "id": "snip-time",
        "keyword": ":time",
        "title": "Current Time (HH:MM)",
        "snippet": "{time}",
        "category": "Dynamic",
    },
    {
        "id": "snip-uuid",
        "keyword": ":uuid",
        "title": "Generate UUID v4",
        "snippet": "{uuid}",
        "category": "Developer",
    },
    {
        "id": "snip-commit",
        "keyword": ":commit",
        "title": "Conventional Commit Template",
        "snippet": "feat(): \n\n- \n- Resolves: #",
        "category": "Git",
    },
    {
        "id": "snip-email",
        "keyword": ":email",
        "title": "Email Address",
        "snippet": "you@example.com",
        "category": "Personal",
    },
]


def init_snippets():
    SNIPPETS_FILE.parent.mkdir(parents=True, exist_ok=True)
    if not SNIPPETS_FILE.exists():
        with open(SNIPPETS_FILE, "w") as f:
            json.dump(DEFAULT_SNIPPETS, f, indent=2)


def load_settings():
    SETTINGS_FILE.parent.mkdir(parents=True, exist_ok=True)
    if not SETTINGS_FILE.exists():
        with open(SETTINGS_FILE, "w") as f:
            json.dump(DEFAULT_SETTINGS, f, indent=2)
        return dict(DEFAULT_SETTINGS)
    try:
        with open(SETTINGS_FILE) as f:
            data = json.load(f)
        out = dict(DEFAULT_SETTINGS)
        out.update(data if isinstance(data, dict) else {})
        return out
    except Exception:
        return dict(DEFAULT_SETTINGS)


def load_snippets():
    init_snippets()
    try:
        with open(SNIPPETS_FILE) as f:
            return json.load(f)
    except Exception:
        return list(DEFAULT_SNIPPETS)


def save_snippets(snippets):
    SNIPPETS_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(SNIPPETS_FILE, "w") as f:
        json.dump(snippets, f, indent=2)


def resolve_template(template_str):
    now = datetime.datetime.now()
    resolved = template_str
    resolved = resolved.replace("{date}", now.strftime("%Y-%m-%d"))
    resolved = resolved.replace("{year}", now.strftime("%Y"))
    resolved = resolved.replace("{month}", now.strftime("%m"))
    resolved = resolved.replace("{day}", now.strftime("%d"))
    resolved = resolved.replace("{time}", now.strftime("%H:%M:%S"))
    resolved = resolved.replace("{uuid}", str(uuid.uuid4()))
    if "{clipboard}" in resolved:
        try:
            clip = subprocess.check_output(
                ["wl-paste", "--no-newline"], text=True, stderr=subprocess.DEVNULL
            )
            resolved = resolved.replace("{clipboard}", clip)
        except Exception:
            resolved = resolved.replace("{clipboard}", "")
    return resolved


def notify(title, body, urgent=False):
    try:
        if shutil.which("omarchy-notification-send"):
            cmd = ["omarchy-notification-send", "-g", "󰅍", title, body]
            if urgent:
                cmd[1:1] = ["-u", "critical"]
            subprocess.run(cmd, timeout=2, check=False,
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            return
        if shutil.which("notify-send"):
            subprocess.run(
                ["notify-send", "-a", "Omnicast", title, body],
                timeout=2, check=False,
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
            )
    except Exception:
        pass


def _run_type(argv, timeout=3):
    return subprocess.run(
        argv, timeout=timeout, check=False,
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )


def type_expanded(text: str, settings: dict | None = None) -> dict:
    """Paste/type expanded text. Returns {ok, backend, error?}."""
    settings = settings or load_settings()
    delay_ms = int(settings.get("delay_ms", 150) or 150)
    prefer = str(settings.get("backend", "auto") or "auto").lower()
    time.sleep(max(0, delay_ms) / 1000.0)

    # Always copy first so Shift+Insert / paste works even if typing fails
    try:
        p = subprocess.Popen(["wl-copy"], stdin=subprocess.PIPE)
        p.communicate(input=text.encode("utf-8"), timeout=2)
    except Exception as e:
        return {"ok": False, "backend": None, "error": f"wl-copy failed: {e}"}

    backends = []
    if prefer in ("wtype", "auto"):
        backends.append("wtype")
    if prefer in ("ydotool", "auto"):
        backends.append("ydotool")
    if prefer not in ("wtype", "ydotool", "auto"):
        backends = ["wtype", "ydotool"]

    last_err = "no typing backend succeeded"
    for backend in backends:
        try:
            if backend == "wtype" and shutil.which("wtype"):
                r = _run_type(["wtype", "-M", "shift", "-k", "Insert", "-m", "shift"])
                if r.returncode == 0:
                    return {"ok": True, "backend": "wtype-shift-insert"}
                r = _run_type(["wtype", text], timeout=4)
                if r.returncode == 0:
                    return {"ok": True, "backend": "wtype"}
                last_err = f"wtype exit {r.returncode}"
            elif backend == "ydotool" and shutil.which("ydotool"):
                # paste: Ctrl+V is unreliable on Wayland; type the text
                r = _run_type(["ydotool", "type", "--", text], timeout=4)
                if r.returncode == 0:
                    return {"ok": True, "backend": "ydotool"}
                last_err = f"ydotool exit {r.returncode}"
            else:
                last_err = f"{backend} not installed"
        except Exception as e:
            last_err = str(e)

    # Copied but could not type: still partial success for manual paste
    return {
        "ok": False,
        "backend": "clipboard-only",
        "error": last_err,
        "copied": True,
    }


def list_snippets():
    results = []
    for s in load_snippets():
        resolved_preview = resolve_template(s.get("snippet", ""))
        results.append({
            "id": s.get("id"),
            "keyword": s.get("keyword"),
            "title": s.get("title"),
            "subtitle": f"Keyword: {s.get('keyword')} • {s.get('category', 'General')}",
            "icon": "⚡",
            "badge": s.get("category", "Snippet"),
            "content": s.get("snippet"),
            "primaryActionTitle": "Insert",
            "markdown": f"### Snippet: {s.get('title')}\n\n```text\n{resolved_preview}\n```\n\n**Keyword:** `{s.get('keyword')}`",
            "metadata": [
                {"label": "Keyword", "value": s.get("keyword")},
                {"label": "Category", "value": s.get("category", "General")},
                {
                    "label": "Template Type",
                    "value": "Dynamic" if "{" in s.get("snippet", "") else "Static",
                },
            ],
        })
    return results


def insert_snippet(snippet_id, notify_on_fail=False):
    target = None
    for s in load_snippets():
        if s.get("id") == snippet_id or s.get("keyword") == snippet_id:
            target = s
            break
    if not target:
        result = {"ok": False, "error": "snippet not found"}
        if notify_on_fail:
            notify("Snippet failed", result["error"], urgent=True)
        return result

    expanded = resolve_template(target.get("snippet", ""))
    result = type_expanded(expanded)
    result["id"] = target.get("id")
    result["keyword"] = target.get("keyword")
    if not result.get("ok"):
        msg = result.get("error") or "typing failed"
        if result.get("copied"):
            msg = f"Copied only: {msg}. Paste with Shift+Insert."
        if notify_on_fail:
            notify("Snippet expand failed", msg, urgent=True)
        result["error"] = msg
    return result


def create_snippet(keyword, title, body, category="General"):
    snippets = load_snippets()
    sid = f"snip-{uuid.uuid4().hex[:8]}"
    snippets.append({
        "id": sid,
        "keyword": keyword,
        "title": title,
        "snippet": body,
        "category": category,
    })
    save_snippets(snippets)
    return {"ok": True, "id": sid}


def delete_snippet(snippet_id):
    snippets = load_snippets()
    snippets = [s for s in snippets if s.get("id") != snippet_id and s.get("keyword") != snippet_id]
    save_snippets(snippets)
    return {"ok": True}


def keywords_map():
    """For the expander daemon: keyword -> template."""
    return {s.get("keyword"): s for s in load_snippets() if s.get("keyword")}


if __name__ == "__main__":
    init_snippets()
    load_settings()
    if len(sys.argv) < 2 or sys.argv[1] == "list":
        print(json.dumps(list_snippets()))
    elif sys.argv[1] == "insert" and len(sys.argv) > 2:
        notify_fail = "--notify" in sys.argv
        print(json.dumps(insert_snippet(sys.argv[2], notify_on_fail=notify_fail)))
    elif sys.argv[1] == "settings":
        print(json.dumps(load_settings()))
    elif sys.argv[1] == "create" and len(sys.argv) > 5:
        print(json.dumps(create_snippet(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])))
    elif sys.argv[1] == "create" and len(sys.argv) > 4:
        print(json.dumps(create_snippet(sys.argv[2], sys.argv[3], sys.argv[4])))
    elif sys.argv[1] == "delete" and len(sys.argv) > 2:
        print(json.dumps(delete_snippet(sys.argv[2])))
    elif sys.argv[1] == "keywords":
        print(json.dumps({k: v.get("snippet") for k, v in keywords_map().items()}))
    else:
        print(json.dumps({"error": "usage"}))
        sys.exit(1)
