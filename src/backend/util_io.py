#!/usr/bin/env python3
"""Safe clipboard / paste helpers for Omnicast (aligned with Omarchy).

Omarchy paste flow:
  1. wl-copy the payload
  2. sleep ~0.15s (launcher must already be dismissed / focus restored)
  3. Shift+Insert (more reliable than Ctrl+V across terminals/apps)
"""
from __future__ import annotations

import os
import subprocess
import sys
import time
from pathlib import Path

from path_safety import allowed_path, deny_reason

MAX_CLIP_BYTES = 20 * 1024 * 1024  # 20 MiB


def _spool_dir() -> Path:
    base = Path(os.environ.get("XDG_RUNTIME_DIR", Path.home() / ".cache" / "omnicast")).resolve()
    base.mkdir(parents=True, exist_ok=True)
    try:
        os.chmod(base, 0o700)
    except Exception:
        pass
    return base


def write_clip_payload(text: str) -> str:
    """Safely store clipboard payload into owner-only 0600 file in runtime dir."""
    spool = _spool_dir() / "clip.spool"
    # Atomic write with strict 0600 permissions
    tmp = _spool_dir() / f"clip.{os.getpid()}.tmp"
    tmp.write_text(text or "", encoding="utf-8", errors="replace")
    os.chmod(tmp, 0o600)
    tmp.replace(spool)
    return str(spool)


def read_clip_payload() -> str:
    """Read and immediately wipe the owner-only clipboard payload."""
    spool = _spool_dir() / "clip.spool"
    if not spool.is_file():
        return ""
    if spool.stat().st_uid != os.getuid() or (spool.stat().st_mode & 0o077) != 0:
        return ""
    text = spool.read_text(encoding="utf-8", errors="replace")
    try:
        spool.unlink(missing_ok=True)
    except Exception:
        pass
    return text


def copy_text(text: str) -> None:
    p = subprocess.Popen(["wl-copy"], stdin=subprocess.PIPE)
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
    proc = subprocess.Popen(["wl-copy", "--type", mime], stdin=subprocess.PIPE)
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
    if op in ("spool-copy", "spool-paste"):
        arg = read_clip_payload()
        op = "copy" if op == "spool-copy" else "paste"
    elif op in ("copy", "paste"):
        # If --stdin or -- is specified, or if no second argument is provided, read securely from stdin
        if len(sys.argv) > 2 and sys.argv[2] in ("--stdin", "--"):
            arg = sys.stdin.read()
        elif len(sys.argv) > 2 and sys.argv[2] == "--file":
            p = Path(sys.argv[3]).resolve()
            if not p.is_file():
                sys.exit(1)
            # Ensure the file is owner-only
            if p.stat().st_uid != os.getuid() or (p.stat().st_mode & 0o077) != 0:
                print("Refusing to read file with insecure permissions", file=sys.stderr)
                sys.exit(1)
            arg = p.read_text(encoding="utf-8", errors="replace")
            try:
                p.unlink(missing_ok=True)
            except Exception:
                pass
        elif len(sys.argv) == 2:
            arg = sys.stdin.read()
        else:
            arg = " ".join(sys.argv[2:])
    else:
        arg = sys.argv[2] if len(sys.argv) > 2 else ""

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
