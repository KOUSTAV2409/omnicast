# Master Roadmap: Omnicast (Omarchy umbrella)

> **Last Updated:** 2026-10-24  
> **Plan:** [`implementation-plan.md`](implementation-plan.md) · **ADRs:** [`memory.md`](memory.md) · **Crosswalk:** [`docs/raycast-vs-omarchy.md`](docs/raycast-vs-omarchy.md)

---

## Doctrine (current)

**Manhattan = non-AI umbrella.** Finished: handoff / own / curate without a model. Ask AI is an optional Ollama / OpenAI-compatible gateway (not a custom Omarchy model).

**Omarchy-LLM is out of band.** Streaming chat uses Ollama or an OpenAI-compatible endpoint. A custom Omarchy model is still a separate mission (ADR 015).

---

## Honest status

| Layer | Status | Reality |
| :--- | :--- | :--- |
| **Identity** | Done | Omarchy umbrella: handoff native tools; match Omarchy menu UX |
| **Shell & search** | Done | Fuzzy + frecency/favorites/aliases, Form, HUD, script modes, catalog cache |
| **Omarchy handoffs** | Done | Clipboard, emoji, theme, background, images, keybindings, menu, capture, share, reminders, Find Files |
| **Omnicast-owned** | Done | Apps, calc, file search, quicklinks, scripts, in-launcher snippets, Windows (Lua/Omarchy), fallbacks |
| **Catalog honesty** | Done | No Web/AI fallbacks while indexes or files are still loading |
| **AI** | Done | Ollama by default; OpenAI-compatible key in `~/.config/omnicast/ai.json` |
| **Visual language** | Done | shell.toml menu/launcher tokens + Hyprland rounding |
| **Public release** | Done | [omnicast.best](https://omnicast.best) + plugin listing + clone-and-run |
| **Packaging** | Plugin done · OPR PR open | Plugin is Omarchy-default; [OPR #1573](https://github.com/omacom/omarchy-pkgs/pull/1573) awaiting maintainer; AUR demoted |

---

## Milestones

| ID | Name | State |
|---|---|---|
| M1 | Trustworthy prototype | Done |
| M2 | Ranking / fuzzy / HUD | Done |
| M3 | Daily tools (calc, scripts, snippets, WM) | Done |
| M4 | Real AI | **Done** (Ollama / OpenAI-compatible; not Omarchy-LLM) |
| M5 | Manhattan complete (non-AI umbrella) | **Done** (2026-10-24) |
| M6 | Berlin underway | **Next** |

---

## What’s left to build

### Berlin (M6)
1. [x] **Omarchy plugin airtight**: plugin-local bar launcher + `omnicast-omarchy-setup` + integration doc
2. [x] **Merge to `main`** so `omarchy plugin add/update` gets current code
3. [x] **OPR package** PR opened: [omacom/omarchy-pkgs#1573](https://github.com/omacom/omarchy-pkgs/pull/1573) (awaiting maintainer build approval / publish)
4. [x] **Deeplinks** + **Hyprland float snaps** + **ADR 016**
5. [x] **Omarchy plugin directory** in the umbrella: search, open the listing, `omarchy plugin add/enable/disable`
6. [x] **AI gateway** (Ollama / OpenAI-compatible): still not Omarchy-LLM

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

**Manhattan (taken):** Raycast power-user **non-AI** daily loop on Omarchy without friction: launch, clipboard, snippets, windows, scripts, calc, web fallback: with HUD and ranking.

**Berlin:** Workflows that feel *better* than Raycast because of Hyprland/Omarchy (deep WM, free clipboard/themes, `omarchy` as OS API, community plugins, local AI). **Omarchy-LLM stays a separate mission.**
