#!/usr/bin/env python3
"""Safe clipboard / paste helpers for Omnicast (aligned with Omarchy).

Omarchy paste flow:
  1. wl-copy the payload
  2. sleep ~0.15s (launcher must already be dismissed / focus restored)
  3. Shift+Insert (more reliable than Ctrl+V across terminals/apps)
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
import time
from pathlib import Path

from path_safety import allowed_path, deny_reason

MAX_CLIP_BYTES = 20 * 1024 * 1024  # 20 MiB


def copy_text(text: str) -> None:
    p = subprocess.Popen(
        ["wl-copy"],
        stdin=subprocess.PIPE,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    p.communicate(input=(text or "").encode("utf-8", errors="replace"))


def _safe_file(path: str) -> Path:
    raw = (path or "").strip()
    if not raw:
        raise ValueError("No path")
    p = Path(raw).expanduser().resolve()
    reason = deny_reason(p)
    if reason:
        raise PermissionError(reason)
    if not allowed_path(p):
        raise PermissionError("Path not allowed")
    if not p.is_file():
        raise FileNotFoundError(str(p))
    if p.stat().st_size > MAX_CLIP_BYTES:
        raise ValueError("File too large for clipboard")
    return p


def copy_file(path: str) -> None:
    p = _safe_file(path)
    data = p.read_bytes()
    mime = "image/png" if p.suffix.lower() == ".png" else "application/octet-stream"
    if p.suffix.lower() in {".jpg", ".jpeg"}:
        mime = "image/jpeg"
    elif p.suffix.lower() == ".webp":
        mime = "image/webp"
    elif p.suffix.lower() == ".gif":
        mime = "image/gif"
    proc = subprocess.Popen(
        ["wl-copy", "--type", mime],
        stdin=subprocess.PIPE,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    proc.communicate(input=data)


def _shift_insert() -> None:
    time.sleep(0.15)
    try:
        subprocess.run(
            ["wtype", "-M", "shift", "-k", "Insert", "-m", "shift"],
            timeout=2,
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except Exception:
        pass


def paste_text(text: str) -> None:
    copy_text(text)
    _shift_insert()


def paste_image(path: str) -> None:
    copy_file(path)
    _shift_insert()


def main():
    if len(sys.argv) < 2:
        print("usage: util_io.py copy|copy-file|paste|paste-image ...", file=sys.stderr)
        sys.exit(1)
    op = sys.argv[1]
    if op in ("copy", "paste"):
        # Process arguments are strictly forbidden for clipboard payload to prevent /proc/<pid>/cmdline leakage.
        # Payload must be passed via stdin (as JSON {"text": ...} or raw string).
        if len(sys.argv) > 2:
            print("Refusing argument: clipboard payload must be passed via stdin", file=sys.stderr)
            sys.exit(1)
        raw = sys.stdin.readline()
        if not raw and not sys.stdin.isatty():
            raw = sys.stdin.read()
        raw = raw.rstrip("\r\n")
        try:
            parsed = json.loads(raw)
            if isinstance(parsed, dict) and "text" in parsed:
                arg = str(parsed["text"])
            elif isinstance(parsed, str):
                arg = parsed
            else:
                arg = raw
        except Exception:
            arg = raw
    elif op == "copy-file":
        arg = sys.argv[2] if len(sys.argv) > 2 else ""
    elif op == "paste-image":
        arg = sys.argv[2] if len(sys.argv) > 2 else ""
    else:
        sys.exit(2)

    try:
        if op == "copy":
            copy_text(arg)
        elif op == "copy-file":
            copy_file(arg)
        elif op == "paste":
            paste_text(arg)
        elif op == "paste-image":
            paste_image(arg)
        else:
            sys.exit(2)
    except Exception as e:
        print(str(e), file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
