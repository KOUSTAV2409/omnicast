# Master Roadmap: Omnicast (Omarchy umbrella)

> **Last Updated:** 2026-10-24  
> **Plan:** [`implementation-plan.md`](implementation-plan.md) · **ADRs:** [`memory.md`](memory.md) · **Crosswalk:** [`docs/raycast-vs-omarchy.md`](docs/raycast-vs-omarchy.md)

---

## Doctrine (current)

**Manhattan = non-AI umbrella.** Finished: handoff / own / curate without a model. Ask AI stays mocked.

**AI is out of band.** Real streaming (Ollama/BYOK) is Berlin+. **Omarchy-LLM** is a separate mission (ADR 015).

---

## Honest status

| Layer | Status | Reality |
| :--- | :--- | :--- |
| **Identity** | Done | Omarchy umbrella: handoff native tools; match Omarchy menu UX |
| **Shell & search** | Done | Fuzzy + frecency/favorites/aliases, Form, HUD, script modes, catalog cache |
| **Omarchy handoffs** | Done | Clipboard, emoji, theme, background, images, keybindings, menu, capture, share, reminders, Find Files |
| **Omnicast-owned** | Done | Apps, calc, file search, quicklinks, scripts, in-launcher snippets, Windows (Lua/Omarchy), fallbacks |
| **Catalog honesty** | Done | No Web/AI fallbacks while indexes or files are still loading |
| **AI** | Deferred | Mock UI only |
| **Visual language** | Done | shell.toml menu/launcher tokens + Hyprland rounding |
| **Public release** | Done | [omnicast.best](https://omnicast.best) + plugin listing + clone-and-run |
| **Packaging** | Plugin done · OPR next | Plugin is Omarchy-default; OPR scaffold in `packaging/opr/`; AUR demoted |

---

## Milestones

| ID | Name | State |
|---|---|---|
| M1 | Trustworthy prototype | Done |
| M2 | Ranking / fuzzy / HUD | Done |
| M3 | Daily tools (calc, scripts, snippets, WM) | Done |
| M4 | Real AI | **Deferred**: after Manhattan; separate from Omarchy-LLM |
| M5 | Manhattan complete (non-AI umbrella) | **Done** (2026-10-24) |
| M6 | Berlin underway | **Next** |

---

## What’s left to build

### Berlin (M6)
1. [x] **Omarchy plugin airtight**: plugin-local bar launcher + `omnicast-omarchy-setup` + integration doc
2. **Merge to `main`** so `omarchy plugin add/update` gets current code
3. **OPR package** PR to `omacom/omarchy-pkgs` (`packaging/opr/`)
4. [x] **Deeplinks** + **Hyprland float snaps** + **ADR 016**
5. **Omarchy plugin store in the umbrella**: [omarchyplugins.com](https://omarchyplugins.com) / [plugins.omarchy.org](https://plugins.omarchy.org)
6. **Optional:** generic AI gateway (Ollama/BYOK): still not Omarchy-LLM

### File search polish (optional)
- Content search as a first-class fast index (not only live `content:` + `rg`)
- Richer Quick Look (PDF/Office thumbnails, media scrubbing)
- Saved scopes / ignore rules / manage UI
- Edge-case polish (encodings, huge trees, mounts)

### Explicitly not building (for now)
- Raycast extension store / full API clone  
- Cloud sync, Teams, Enterprise  
- Dictation, Focus, Calendar, Notes  
- Rewriting UI outside Quickshell  
- Training or shipping a custom Omarchy LLM inside this repo  
- Global keystroke snippet daemon (removed; in-launcher snippets only)

Authoritative checkboxes: [`implementation-plan.md`](implementation-plan.md) §5 (M4-M6).

---

## What “done” means

**Manhattan (taken):** Raycast power-user **non-AI** daily loop on Omarchy without friction: launch, clipboard, snippets, windows, scripts, calc, web fallback: with HUD and ranking. Ask AI may remain mocked.

**Berlin:** Workflows that feel *better* than Raycast because of Hyprland/Omarchy (deep WM, free clipboard/themes, `omarchy` as OS API, community plugins). Local AI (generic gateway) is optional Berlin+; **Omarchy-LLM stays a separate mission.**
