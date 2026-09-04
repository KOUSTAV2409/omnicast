# Master Roadmap: Omnicast (Omarchy umbrella)

> **Last Updated:** 2026-09-04  
> **Plan:** [`implementation-plan.md`](implementation-plan.md) · **ADRs:** [`memory.md`](memory.md) · **Crosswalk:** [`docs/raycast-vs-omarchy.md`](docs/raycast-vs-omarchy.md)

---

## Honest status

| Layer | Status | Reality |
| :--- | :--- | :--- |
| **Identity** | Done | Omarchy umbrella — handoff native tools; match Omarchy menu UX |
| **Shell & search** | Done | Fuzzy + frecency/favorites/aliases, Form, HUD, script modes |
| **Omarchy handoffs** | Done | Clipboard, emoji, theme, background, images, keybindings, menu, capture, share, reminders |
| **Omnicast-owned** | Mostly | Apps, calc, quicklinks, scripts, snippets, Windows (Lua/Omarchy), fallbacks |
| **AI** | Mock | Ask AI UI only — streaming Ollama/BYOK is next (M4) |
| **Visual language** | Done | shell.toml menu/launcher tokens + Hyprland rounding |
| **Public release** | Not yet | Private dogfood |

---

## Milestones

| ID | Name | State |
|---|---|---|
| M1 | Trustworthy prototype | Done |
| M2 | Ranking / fuzzy / HUD | Done |
| M3 | Daily tools (calc, scripts, snippets, WM) | Done |
| M4 | Real AI | Next |
| M5 | Manhattan complete (umbrella) | ~90% — blocked on M4 (+ optional file search) |

---

## What “done” means

**Manhattan:** Raycast power-user daily loop on Omarchy without friction — launch, clipboard, snippets, windows, scripts, calc, ask AI — with HUD and ranking.  

**Berlin:** Workflows that feel *better* than Raycast because of Hyprland/Omarchy (deep WM, free clipboard/themes, local AI, `omarchy` as OS API).
