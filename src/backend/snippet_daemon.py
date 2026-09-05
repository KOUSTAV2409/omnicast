#!/usr/bin/env python3
"""
Omnicast global snippet expander (best-effort Wayland).

Listens for keyboard events via python-evdev when available and expands
configured keywords (e.g. :shrug) using clipboard + wtype/ydotool.

Settings: ~/.config/omnicast/snippetd.json
  { "delay_ms": 150, "backend": "auto" }   # auto | wtype | ydotool

Requires: user in `input` group, python-evdev installed.
On expand failure: desktop notification (and text still copied when possible).

Usage:
  omnicast-snippetd
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


def expand_keyword(keyword: str) -> dict:
    try:
        out = subprocess.check_output(
            ["python3", str(MANAGER), "insert", keyword, "--notify"],
            text=True,
            timeout=8,
        )
        return json.loads(out or "{}")
    except Exception as e:
        return {"ok": False, "error": str(e)}


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
        print("[snippetd] no keywords configured: add some in Omnicast → Snippets", file=sys.stderr)

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
        print("[snippetd] no input devices readable: check `input` group", file=sys.stderr)
        sys.exit(3)

    print(
        f"[snippetd] watching {len(devices)} devices, {len(keywords)} keywords "
        f"(settings: ~/.config/omnicast/snippetd.json)",
        flush=True,
    )

    buffer = ""
    last_reload = time.time()
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
                if len(buffer) > 32:
                    buffer = buffer[-32:]

                for kw in keywords:
                    if buffer.endswith(kw):
                        try:
                            for _ in range(len(kw)):
                                subprocess.run(
                                    ["wtype", "-k", "BackSpace"],
                                    timeout=0.5,
                                    check=False,
                                    stdout=subprocess.DEVNULL,
                                    stderr=subprocess.DEVNULL,
                                )
                            result = expand_keyword(kw)
                            if result.get("ok"):
                                print(f"[snippetd] expanded {kw} via {result.get('backend')}", flush=True)
                            else:
                                print(
                                    f"[snippetd] expand failed for {kw}: {result.get('error')}",
                                    file=sys.stderr,
                                )
                        except Exception as e:
                            print(f"[snippetd] expand failed: {e}", file=sys.stderr)
                        buffer = ""
                        break


if __name__ == "__main__":
    main()
