#!/usr/bin/env python3
import json
import uuid
import datetime
import subprocess
import sys
import time
from pathlib import Path

SNIPPETS_FILE = Path.home() / ".config/omnicast/snippets.json"

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


def insert_snippet(snippet_id):
    target = None
    for s in load_snippets():
        if s.get("id") == snippet_id or s.get("keyword") == snippet_id:
            target = s
            break
    if not target:
        return
    expanded = resolve_template(target.get("snippet", ""))
    p = subprocess.Popen(["wl-copy"], stdin=subprocess.PIPE)
    p.communicate(input=expanded.encode("utf-8"))
    # Match Omarchy: wait for launcher dismiss + focus restore, then Shift+Insert
    try:
        time.sleep(0.15)
        subprocess.run(
            ["wtype", "-M", "shift", "-k", "Insert", "-m", "shift"],
            timeout=2,
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except Exception:
        try:
            subprocess.run(["wtype", expanded], timeout=2, check=False)
        except Exception:
            pass


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
    if len(sys.argv) < 2 or sys.argv[1] == "list":
        print(json.dumps(list_snippets()))
    elif sys.argv[1] == "insert" and len(sys.argv) > 2:
        insert_snippet(sys.argv[2])
        print(json.dumps({"status": "inserted"}))
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
