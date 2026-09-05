# Master Roadmap: Omnicast (Omarchy umbrella)

> **Last Updated:** 2026-09-05  
> **Plan:** [`implementation-plan.md`](implementation-plan.md) · **ADRs:** [`memory.md`](memory.md) · **Crosswalk:** [`docs/raycast-vs-omarchy.md`](docs/raycast-vs-omarchy.md)

---

## Doctrine (current)

**Manhattan = non-AI umbrella.** Finish every handoff / own / curate tool that does not need a model. Do **not** ship real AI to close Manhattan.

**AI is out of band.** Mock Ask AI may stay as a stub. Real streaming (Ollama/BYOK) is **after** Manhattan — and is **not** the Omarchy-LLM mission.

**Omarchy-LLM** (ultra-light local model for Omarchy OS tasks) is a **separate mission**, outside this repo’s mainstream goal. Do not couple Omnicast Manhattan/Berlin to that research track.

---

## Honest status

| Layer | Status | Reality |
| :--- | :--- | :--- |
| **Identity** | Done | Omarchy umbrella — handoff native tools; match Omarchy menu UX |
| **Shell & search** | Done | Fuzzy + frecency/favorites/aliases, Form, HUD, script modes, catalog cache |
| **Omarchy handoffs** | Done | Clipboard, emoji, theme, background, images, keybindings, menu, capture, share, reminders, Find Files |
| **Omnicast-owned** | Done | Apps, calc, quicklinks, scripts, snippets, Windows (Lua/Omarchy), fallbacks |
| **AI** | Deferred | Mock UI only — **not required for Manhattan**; real AI later; Omarchy-LLM elsewhere |
| **Visual language** | Done | shell.toml menu/launcher tokens + Hyprland rounding |
| **Public release** | Open | [omnicast.best](https://omnicast.best) + public clone-and-run; packaging later |

---

## Milestones

| ID | Name | State |
|---|---|---|
| M1 | Trustworthy prototype | Done |
| M2 | Ranking / fuzzy / HUD | Done |
| M3 | Daily tools (calc, scripts, snippets, WM) | Done |
| M4 | Real AI | **Deferred** — after Manhattan; separate from Omarchy-LLM |
| M5 | Manhattan complete (non-AI umbrella) | **Next** — close remaining non-AI gaps |
| M6 | Berlin underway | Later |

---

## What’s left to build

### Must finish for Manhattan (non-AI only)
Ordered checklist: [`docs/work-order.md`](docs/work-order.md).

Audit [`docs/raycast-vs-omarchy.md`](docs/raycast-vs-omarchy.md) and ship any remaining **handoff / own / curate** gaps that do not need a model. Candidate polish (reconfirm against dogfood):

1. **Root / catalog honesty** — empty states, mid-scan UX, no false web/AI fallbacks while catalogs load  
2. **Script commands polish** — arg forms, failure HUD, docs for `~/.config/omnicast/commands/`  
3. **Windows / Hyprland helpers** — any broken or missing daily actions from the curated list  
4. **Quicklinks / snippets / calc** — edge cases from real use (not new feature families)  
5. **Dogfood pass** — Raycast-shaped daily loop without Ask AI: launch → clipboard → emoji → theme → files → snippets → windows → scripts → calc → web fallback  

When that loop is trustworthy, **declare Manhattan taken** — even with mock AI.

### Explicitly deferred (not Manhattan)
- Real AI streaming (Ollama / BYOK)  
- Quick AI from root / clipboard explain-summarize  
- **Omarchy-LLM** (separate mission — do not plan inside Omnicast milestones)

### Berlin (M6 — after Manhattan)
6. [x] **Public clone path** — omnicast.best + public repo  
7. **Packaging / install path** — AUR / omarchy plugin  
8. **Deeplinks** — `omnicast://…`  
9. **One Hyprland-only killer workflow**  
10. **Omarchy plugin store in the umbrella** — [omarchyplugins.com](https://omarchyplugins.com)  
11. **Extension strategy ADR** — scripts-first; Omarchy registry next; never Raycast Store clone  
12. **Optional:** wire real AI gateway (generic Ollama/BYOK) — still not Omarchy-LLM  

### Maps we already have (north star inputs)
- Raycast feature matrix → [`docs/spec/raycast-feature-matrix.md`](docs/spec/raycast-feature-matrix.md) + [`docs/raycast-vs-omarchy.md`](docs/raycast-vs-omarchy.md)
- Omarchy tools / handoffs → same crosswalk + `/usr/share/omarchy`
- Eventual goal → umbrella: handoff · own · curate (including community plugins)

### Explicitly not building (for now)
- Raycast extension store / full API clone  
- Cloud sync, Teams, Enterprise  
- Dictation, Focus, Calendar, Notes  
- Rewriting UI outside Quickshell  
- Training or shipping a custom Omarchy LLM inside this repo  

Authoritative checkboxes: [`implementation-plan.md`](implementation-plan.md) §5 (M4–M6).

---

## What “done” means

**Manhattan:** Raycast power-user **non-AI** daily loop on Omarchy without friction — launch, clipboard, snippets, windows, scripts, calc, web fallback — with HUD and ranking. Ask AI may remain mocked.

**Berlin:** Workflows that feel *better* than Raycast because of Hyprland/Omarchy (deep WM, free clipboard/themes, `omarchy` as OS API, community plugins). Local AI (generic gateway) is optional Berlin+; **Omarchy-LLM stays a separate mission.**
