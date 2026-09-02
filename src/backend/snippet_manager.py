#!/usr/bin/env python3
import os
import sys
import json
import uuid
import datetime
import subprocess
from pathlib import Path

SNIPPETS_FILE = Path.home() / ".config/omnicast/snippets.json"

DEFAULT_SNIPPETS = [
    {
        "id": "snip-shrug",
        "keyword": ":shrug",
        "title": "¯\\_(ツ)_/¯ (Shrug)",
        "snippet": "¯\\_(ツ)_/¯",
        "category": "Emojis"
    },
    {
        "id": "snip-date",
        "keyword": ":date",
        "title": "Current Date (YYYY-MM-DD)",
        "snippet": "{date}",
        "category": "Dynamic"
    },
    {
        "id": "snip-time",
        "keyword": ":time",
        "title": "Current Time (HH:MM)",
        "snippet": "{time}",
        "category": "Dynamic"
    },
    {
        "id": "snip-uuid",
        "keyword": ":uuid",
        "title": "Generate UUID v4",
        "snippet": "{uuid}",
        "category": "Developer"
    },
    {
        "id": "snip-commit",
        "keyword": ":commit",
        "title": "Conventional Commit Template",
        "snippet": "feat(): \n\n- \n- Resolves: #",
        "category": "Git"
    },
    {
        "id": "snip-email",
        "keyword": ":email",
        "title": "My Email Address",
        "snippet": "iamkxyz@gmail.com",
        "category": "Personal"
    }
]

def init_snippets():
    SNIPPETS_FILE.parent.mkdir(parents=True, exist_ok=True)
    if not SNIPPETS_FILE.exists():
        with open(SNIPPETS_FILE, "w") as f:
            json.dump(DEFAULT_SNIPPETS, f, indent=2)

def load_snippets():
    init_snippets()
    try:
        with open(SNIPPETS_FILE, "r") as f:
            return json.load(f)
    except:
        return DEFAULT_SNIPPETS

def resolve_template(template_str):
    now = datetime.datetime.now()
    resolved = template_str
    
    # {date} -> YYYY-MM-DD
    resolved = resolved.replace("{date}", now.strftime("%Y-%m-%d"))
    resolved = resolved.replace("{year}", now.strftime("%Y"))
    resolved = resolved.replace("{month}", now.strftime("%m"))
    resolved = resolved.replace("{day}", now.strftime("%d"))
    resolved = resolved.replace("{time}", now.strftime("%H:%M:%S"))
    resolved = resolved.replace("{uuid}", str(uuid.uuid4()))
    
    # {clipboard}
    if "{clipboard}" in resolved:
        try:
            clip = subprocess.check_output(["wl-paste", "--no-newline"], text=True, stderr=subprocess.DEVNULL)
            resolved = resolved.replace("{clipboard}", clip)
        except:
            resolved = resolved.replace("{clipboard}", "")
            
    return resolved

def list_snippets():
    snippets = load_snippets()
    results = []
    for s in snippets:
        resolved_preview = resolve_template(s.get("snippet", ""))
        results.append({
            "id": s.get("id"),
            "keyword": s.get("keyword"),
            "title": s.get("title"),
            "subtitle": f"Keyword: {s.get('keyword')} • {s.get('category', 'General')}",
            "icon": "⚡",
            "badge": s.get("category", "Snippet"),
            "content": s.get("snippet"),
            "markdown": f"### Snippet: {s.get('title')}\n\n```text\n{resolved_preview}\n```\n\n**Keyword Trigger:** `{s.get('keyword')}`\n\n**Raw Template:** `{s.get('snippet')}`",
            "metadata": [
                { "label": "Keyword", "value": s.get("keyword") },
                { "label": "Category", "value": s.get("category", "General") },
                { "label": "Template Type", "value": "Dynamic" if "{" in s.get("snippet", "") else "Static" }
            ]
        })
    return results

def insert_snippet(snippet_id):
    snippets = load_snippets()
    target = None
    for s in snippets:
        if s.get("id") == snippet_id or s.get("keyword") == snippet_id:
            target = s
            break
            
    if not target:
        return
        
    expanded = resolve_template(target.get("snippet", ""))
    
    # Copy to clipboard and type via wtype
    p = subprocess.Popen(["wl-copy"], stdin=subprocess.PIPE)
    p.communicate(input=expanded.encode("utf-8"))
    
    # Attempt wtype keystroke insertion
    try:
        subprocess.run(["wtype", expanded], timeout=1)
    except:
        pass

if __name__ == "__main__":
    init_snippets()
    if len(sys.argv) < 2 or sys.argv[1] == "list":
        print(json.dumps(list_snippets()))
    elif sys.argv[1] == "insert" and len(sys.argv) > 2:
        insert_snippet(sys.argv[2])
        print(json.dumps({"status": "inserted"}))
