# Master Roadmap: Omnicast (Omarchy umbrella)

> **Last Updated:** 2026-09-05  
> **Plan:** [`implementation-plan.md`](implementation-plan.md) · **ADRs:** [`memory.md`](memory.md) · **Crosswalk:** [`docs/raycast-vs-omarchy.md`](docs/raycast-vs-omarchy.md)

---

## Honest status

| Layer | Status | Reality |
| :--- | :--- | :--- |
| **Identity** | Done | Omarchy umbrella — handoff native tools; match Omarchy menu UX |
| **Shell & search** | Done | Fuzzy + frecency/favorites/aliases, Form, HUD, script modes, catalog cache |
| **Omarchy handoffs** | Done | Clipboard, emoji, theme, background, images, keybindings, menu, capture, share, reminders |
| **Omnicast-owned** | Done | Apps, calc, quicklinks, scripts, snippets, Windows (Lua/Omarchy), fallbacks |
| **AI** | Mock | Ask AI UI only — streaming Ollama/BYOK is next (M4) |
| **Visual language** | Done | shell.toml menu/launcher tokens + Hyprland rounding |
| **Public release** | Open | Public repo + clone-and-run; packaging later |

---

## Milestones

| ID | Name | State |
|---|---|---|
| M1 | Trustworthy prototype | Done |
| M2 | Ranking / fuzzy / HUD | Done |
| M3 | Daily tools (calc, scripts, snippets, WM) | Done |
| M4 | Real AI | **Next** |
| M5 | Manhattan complete (umbrella) | ~90% — blocked on M4 (+ optional file search) |
| M6 | Berlin underway | Later |

---

## What’s left to build

### Must build next (M4 — closes Manhattan on paper)
1. **Real AI streaming** — Ollama default + OpenAI-compatible BYOK (replace mock)
2. **Quick AI from root** — fallback / question-shaped queries hit the real model
3. **AI context actions** — explain / summarize clipboard or selection

### Should build (optional Manhattan polish)
4. [x] **File search** — `Find Files` handoff via `omarchy-file-select` (`bin/omnicast-open-file`)
5. [x] **Snippetd reliability** — `snippetd.json` delay/backend, wtype→ydotool fallback, failure HUD/notify
6. [x] **Calc depth** — currency (approx static FX) + dates (`today`, `days until …`)

### Berlin (M6 — after M4)
7. [x] **Public clone path** — repo public; site + README install (no invite gate)
8. **Packaging / install path** — AUR / omarchy plugin (still open)
9. **Deeplinks** — `omnicast://…` style invoke
10. **One Hyprland-only killer workflow** — clearly better than Raycast
11. **Extension strategy ADR** — scripts-first vs store later

### Explicitly not building (for now)
- Raycast extension store / full API clone  
- Cloud sync, Teams, Enterprise  
- Dictation, Focus, Calendar, Notes  
- Rewriting UI outside Quickshell  

Authoritative checkboxes: [`implementation-plan.md`](implementation-plan.md) §5 (M4–M6).

---

## What “done” means

**Manhattan:** Raycast power-user daily loop on Omarchy without friction — launch, clipboard, snippets, windows, scripts, calc, ask AI — with HUD and ranking.  

**Berlin:** Workflows that feel *better* than Raycast because of Hyprland/Omarchy (deep WM, free clipboard/themes, local AI, `omarchy` as OS API).
