# Project Context: Omnicast

> **Document Type:** Agent & LLM Knowledge Base / Core Context  
> **Status:** Active: Omarchy umbrella (ADR 014)  
> **Last Updated:** 2026-09-04  

---

## 1. Executive summary

**Omnicast** is a keyboard-first productivity launcher for **Omarchy** (Hyprland + Quickshell).

**Doctrine (ADR 014):** Omnicast is an **Omarchy umbrella**, not a Raycast UI clone.

1. **Handoff** where Omarchy is already strong (clipboard, emoji, themes, images, menu, …).  
2. **Own** true gaps (ranked root search, calc, quicklinks, scripts, snippets, curated WM).  
3. **Curate** fragmented Hyprland/Omarchy CLIs into searchable lists.

Hotkey: **Alt+Space** → `bin/omnicast` (Super+Space stays Omarchy menu).

---

## 2. Non-negotiables

1. Match Omarchy menu/clipboard visual language: not Raycast chrome.  
2. Keyboard-first: Enter / Ctrl+K / Esc ladder on every view.  
3. Prefer Omarchy CLI + state over reimplementing daemons.  
4. Hyprland via **Lua dispatch** / `omarchy-hyprland-*`: classic `hyprctl dispatch setfloating` is broken on Omarchy.  
5. Portable paths via `Paths` / `Quickshell.shellDir`: no hardcoded home dirs.

---

## 3. Host environment

- **OS:** Omarchy (Arch)  
- **Compositor:** Hyprland (Wayland, Lua config)  
- **UI:** Quickshell (Qt6 / QML), `wlr-layer-shell`  
- **Terminals:** Ghostty / Foot / Kitty / Alacritty (`$TERMINAL`)

---

## 4. What ships today (product surface)

| Surface | Mode |
|---|---|
| Apps, Omarchy commands, scripts | Own |
| Calc (math / color / units) | Own |
| Quicklinks, snippets (+ optional snippetd) | Own |
| Windows (pop, gaps, float, fullscreen, …) | Curate / own |
| Clipboard, emoji, theme, images, keybindings, menu | Handoff |
| Ask AI | Mock UI only |
| File search | Prefer Omarchy handoff |

---

## 5. Layout

```
omnicast/
├── README.md                 # Product offering (start here)
├── roadmap.md                # Status
├── implementation-plan.md    # Manhattan → Berlin
├── memory.md                 # ADRs
├── context.md                # THIS FILE
├── docs/
│   ├── raycast-vs-omarchy.md
│   ├── script-commands.md
│   └── spec/
├── bin/omnicast              # Launch / toggle
├── bin/omnicast-snippetd     # Optional global expander
└── src/                      # QML + Python backends
```

---

## 6. Agent pointers

- Decisions & invariants → [`memory.md`](memory.md)  
- Execution checklist → [`implementation-plan.md`](implementation-plan.md)  
- Raycast vs Omarchy map → [`docs/raycast-vs-omarchy.md`](docs/raycast-vs-omarchy.md)  
- Do **not** commit `omnicastagentlink.md` or local agent secrets
