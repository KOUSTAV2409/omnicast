#!/usr/bin/env python3
"""Hyprland floating layout snaps (Berlin killer workflow).

Raycast WM is constrained by macOS Accessibility. Omarchy Hyprland gives exact
geometry via Lua dispatch. This places the *active* window into a named region
of the focused monitor (respecting reserved bar space).

Usage:
  window_snap.py list
  window_snap.py apply <preset>
"""
from __future__ import annotations

import json
import re
import subprocess
import sys
from typing import Any

# Hyprland window addresses are hex pointers (e.g. 0x56a1b2c3).
_ADDR_RE = re.compile(r"^0x[0-9a-fA-F]{1,16}$")

# Small inset so snapped floats don't kiss the bar / edges.
GAP = 8

# preset -> (fx, fy, fw, fh) fractions of usable monitor rect
PRESETS: dict[str, tuple[float, float, float, float]] = {
    "left": (0.0, 0.0, 0.5, 1.0),
    "right": (0.5, 0.0, 0.5, 1.0),
    "top": (0.0, 0.0, 1.0, 0.5),
    "bottom": (0.0, 0.5, 1.0, 0.5),
    "left-third": (0.0, 0.0, 1.0 / 3.0, 1.0),
    "center-third": (1.0 / 3.0, 0.0, 1.0 / 3.0, 1.0),
    "right-third": (2.0 / 3.0, 0.0, 1.0 / 3.0, 1.0),
    "top-left": (0.0, 0.0, 0.5, 0.5),
    "top-right": (0.5, 0.0, 0.5, 0.5),
    "bottom-left": (0.0, 0.5, 0.5, 0.5),
    "bottom-right": (0.5, 0.5, 0.5, 0.5),
    "center": (0.2, 0.15, 0.6, 0.7),
    "maximize": (0.0, 0.0, 1.0, 1.0),
}

TITLES = {
    "left": "Left Half",
    "right": "Right Half",
    "top": "Top Half",
    "bottom": "Bottom Half",
    "left-third": "Left Third",
    "center-third": "Center Third",
    "right-third": "Right Third",
    "top-left": "Top Left",
    "top-right": "Top Right",
    "bottom-left": "Bottom Left",
    "bottom-right": "Bottom Right",
    "center": "Center",
    "maximize": "Maximize (float)",
}


def _run(argv: list[str]) -> str:
    return subprocess.check_output(argv, text=True, stderr=subprocess.DEVNULL)


def _hypr_json(cmd: str) -> Any:
    return json.loads(_run(["hyprctl", "-j", cmd]))


def _dispatch(lua: str, *classic: str) -> None:
    # Omarchy Lua-first; classic argv is the same fallback pattern as omarchy-hyprland-window-pop.
    try:
        subprocess.run(
            ["hyprctl", "dispatch", lua],
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        if classic:
            subprocess.run(
                ["hyprctl", "dispatch", *classic],
                check=False,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
    except OSError as e:
        raise SystemExit(json.dumps({"ok": False, "error": str(e)}))


def usable_rect(mon: dict[str, Any]) -> tuple[int, int, int, int]:
    reserved = mon.get("reserved") or [0, 0, 0, 0]
    # Hyprland reserved: [top, right, bottom, left]
    top, right, bottom, left = (int(reserved[i]) if i < len(reserved) else 0 for i in range(4))
    mx = int(mon.get("x") or 0)
    my = int(mon.get("y") or 0)
    mw = int(mon.get("width") or 0)
    mh = int(mon.get("height") or 0)
    x = mx + left + GAP
    y = my + top + GAP
    w = max(100, mw - left - right - GAP * 2)
    h = max(100, mh - top - bottom - GAP * 2)
    return x, y, w, h


def focused_monitor(monitors: list[dict[str, Any]], win: dict[str, Any]) -> dict[str, Any]:
    mid = win.get("monitor")
    for m in monitors:
        if m.get("id") == mid:
            return m
    for m in monitors:
        if m.get("focused"):
            return m
    if not monitors:
        raise RuntimeError("no monitors")
    return monitors[0]


def apply(preset: str) -> dict[str, Any]:
    key = preset.strip().lower().replace("_", "-").replace(" ", "-")
    if key not in PRESETS:
        return {"ok": False, "error": f"unknown preset: {preset}", "presets": sorted(PRESETS)}

    win = _hypr_json("activewindow")
    addr = str(win.get("address") or "")
    if not addr or addr in ("0x0", "0") or not _ADDR_RE.fullmatch(addr):
        return {"ok": False, "error": "no active window"}

    monitors = _hypr_json("monitors")
    mon = focused_monitor(monitors, win)
    ux, uy, uw, uh = usable_rect(mon)
    fx, fy, fw, fh = PRESETS[key]
    x = int(round(ux + uw * fx))
    y = int(round(uy + uh * fy))
    w = int(round(uw * fw))
    h = int(round(uh * fh))
    # Keep last pixel inside usable rect
    w = max(80, min(w, ux + uw - x))
    h = max(80, min(h, uy + uh - y))
    # Geometry is int-only in Lua strings below — never interpolate raw strings
    # except the already-validated hex address.
    x, y, w, h = int(x), int(y), int(w), int(h)

    window = f"address:{addr}"

    # Leave fullscreen / maximized so float geometry sticks (Cursor etc. use mode 2).
    fs = int(win.get("fullscreen") or 0)
    if fs == 1 or fs == 3:
        _dispatch(
            f'hl.dsp.window.fullscreen({{ window = "{window}", mode = "fullscreen" }})',
            "fullscreen",
            window,
        )
    if fs == 2 or fs == 3:
        _dispatch(
            f'hl.dsp.window.fullscreen({{ window = "{window}", mode = "maximized" }})',
            "fullscreen",
            "1",
            window,
        )

    if not win.get("floating"):
        _dispatch(
            f'hl.dsp.window.float({{ window = "{window}", action = "toggle" }})',
            "togglefloating",
            window,
        )

    # Prefer absolute pixel ops (more reliable on Lua Hyprland than relative moveactive).
    _dispatch(
        f'hl.dsp.window.resize({{ window = "{window}", x = {w}, y = {h} }})',
        "resizeactive",
        "exact",
        str(w),
        str(h),
    )
    _dispatch(
        f'hl.dsp.window.move({{ window = "{window}", x = {x}, y = {y} }})',
        "moveactive",
        "exact",
        str(x),
        str(y),
    )

    return {
        "ok": True,
        "preset": key,
        "title": TITLES.get(key, key),
        "geometry": {"x": x, "y": y, "w": w, "h": h},
        "monitor": mon.get("name"),
        "window": addr,
    }


def list_presets() -> list[dict[str, str]]:
    return [{"id": k, "title": TITLES[k]} for k in PRESETS]


def main(argv: list[str]) -> int:
    if len(argv) < 2 or argv[1] in ("-h", "--help", "help"):
        print(
            json.dumps(
                {
                    "ok": False,
                    "error": "usage: list | apply <preset>",
                    "presets": sorted(PRESETS),
                }
            )
        )
        return 1
    cmd = argv[1]
    if cmd == "list":
        print(json.dumps({"ok": True, "presets": list_presets()}))
        return 0
    if cmd == "apply":
        if len(argv) < 3:
            print(json.dumps({"ok": False, "error": "apply needs preset"}))
            return 1
        try:
            result = apply(argv[2])
        except (OSError, subprocess.CalledProcessError, json.JSONDecodeError, RuntimeError) as e:
            print(json.dumps({"ok": False, "error": str(e)}))
            return 1
        print(json.dumps(result))
        return 0 if result.get("ok") else 1
    print(json.dumps({"ok": False, "error": f"unknown command: {cmd}"}))
    return 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
