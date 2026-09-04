#!/usr/bin/env python3
"""
Omnicast global snippet expander (best-effort Wayland).

Listens for keyboard events via python-evdev when available and expands
configured keywords (e.g. :shrug) using backspace + wtype.

Requires: user in `input` group, python-evdev installed.
Fallback: prints instructions and exits non-zero if evdev unavailable.

Usage:
  omnicast-snippetd
  systemctl --user enable --now omnicast-snippetd.service  # if packaged
"""
from __future__ import annotations

import json
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent
MANAGER = ROOT / "snippet_manager.py"


def load_keywords():
    try:
        out = subprocess.check_output(
            ["python3", str(MANAGER), "keywords"], text=True
        )
        return json.loads(out)
    except Exception as e:
        print(f"[snippetd] failed to load keywords: {e}", file=sys.stderr)
        return {}


def expand_and_type(keyword: str, template: str):
    # Resolve via manager insert by keyword
    subprocess.run(["python3", str(MANAGER), "insert", keyword], check=False)


def main():
    try:
        import evdev
        from evdev import categorize, ecodes
    except ImportError:
        print(
            "[snippetd] python-evdev not installed. "
            "Install with: pacman -S python-evdev (and add user to `input` group).",
            file=sys.stderr,
        )
        sys.exit(2)

    keywords = load_keywords()
    if not keywords:
        print("[snippetd] no keywords configured", file=sys.stderr)

    # Pick first keyboard-like device
    devices = []
    for path in evdev.list_devices():
        try:
            d = evdev.InputDevice(path)
            caps = d.capabilities()
            if ecodes.EV_KEY in caps:
                devices.append(d)
        except Exception:
            continue

    if not devices:
        print("[snippetd] no input devices readable — check `input` group", file=sys.stderr)
        sys.exit(3)

    print(f"[snippetd] watching {len(devices)} devices, {len(keywords)} keywords", flush=True)

    buffer = ""
    last_reload = time.time()
    # Map keycodes to chars for simple US-ish layout (letters, digits, colon)
    # For a fuller layout, use xkb — this is intentionally minimal.
    SHIFT = set()

    from select import select

    while True:
        if time.time() - last_reload > 5:
            keywords = load_keywords()
            last_reload = time.time()

        r, _, _ = select(devices, [], [], 1.0)
        for dev in r:
            for event in dev.read():
                if event.type != ecodes.EV_KEY:
                    continue
                key = categorize(event)
                if key.keystate != key.key_down:
                    if key.keycode in ("KEY_LEFTSHIFT", "KEY_RIGHTSHIFT"):
                        SHIFT.discard(key.keycode)
                    continue
                code = key.keycode
                if code in ("KEY_LEFTSHIFT", "KEY_RIGHTSHIFT"):
                    SHIFT.add(code)
                    continue
                ch = None
                if code.startswith("KEY_") and len(code) == 5:
                    letter = code[-1].lower()
                    if "a" <= letter <= "z":
                        ch = letter.upper() if SHIFT else letter
                elif code.startswith("KEY_") and code[4:].isdigit():
                    ch = code[4:]
                elif code == "KEY_SEMICOLON":
                    ch = ":" if SHIFT else ";"
                elif code == "KEY_MINUS":
                    ch = "_" if SHIFT else "-"
                elif code == "KEY_SPACE":
                    buffer = ""
                    continue
                elif code == "KEY_ENTER":
                    buffer = ""
                    continue
                elif code == "KEY_BACKSPACE":
                    buffer = buffer[:-1]
                    continue

                if ch is None:
                    continue
                buffer += ch
                # Keep buffer short
                if len(buffer) > 32:
                    buffer = buffer[-32:]

                for kw, template in keywords.items():
                    if buffer.endswith(kw):
                        # Delete keyword chars then expand
                        try:
                            for _ in range(len(kw)):
                                subprocess.run(
                                    ["wtype", "-k", "BackSpace"],
                                    timeout=0.5,
                                    check=False,
                                )
                            expand_and_type(kw, template)
                        except Exception as e:
                            print(f"[snippetd] expand failed: {e}", file=sys.stderr)
                        buffer = ""
                        break


if __name__ == "__main__":
    main()
