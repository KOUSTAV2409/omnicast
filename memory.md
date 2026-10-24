# Project Memory: Omnicast

> **Document Type:** Living Memory, Architectural Decision Records (ADRs), Lessons Learned & Project State  
> **Concept:** Agent Wiki / Continuous LLM Knowledge Base (Karpathy Pattern)  
> **Status:** Active  
> **Last Synchronized:** 2026-09-05  

---

## 1. Project Invariants & Guiding Laws

Whenever any agent or developer touches this project, the following rules MUST be upheld:

1. **Aesthetic Parity**: Never sacrifice visual elegance for expediency. Every view must include subtle borders, balanced padding, readable font hierarchies, active-selection accents, and smooth transitions.
2. **The `Ctrl+K` Contract**: Every selectable item in every view MUST have a primary action (`Enter`) and an Action Palette trigger (`Ctrl+K` or `Tab`) with context-aware secondary operations.
3. **Deep Native Omarchy Integration**: Rather than building generic standalone Linux daemons from scratch, Omnicast is the premier Raycast-grade front-end deeply woven into Omarchy's existing state, clipboard JSON history, and 100+ native system commands.
4. **Layer-Shell Protocol Compliance**: The UI must be implemented as a Wayland overlay window using `wlr-layer-shell` with exclusive keyboard focus while active, and instant dismiss on `Esc` or background click.
5. **System Keybinding Contract**:
   - `SUPER + SPACE`: Preserved for standard Omarchy System Menu.
   - `ALT + SPACE`: Bound globally to Omnicast (`~/Projects/omnicast/bin/omnicast`).

---

## 2. Chronological Milestones & Event Log

### [2026-09-02] - Architectural Pivot: Deep Omarchy-Native Fusion
- **Milestone**: Shifted architecture from generic Linux daemons to deep integration with Omarchy's native state files and CLI commands.
- **Key Upgrades**:
  - **Native Clipboard Bridge**: Directly reads and parses `~/.local/state/omarchy/clipboard-history.json` and `~/.local/state/omarchy/clipboard-images/`, eliminating duplicate background daemons.
  - **Omarchy Command Catalog**: Added `src/backend/omarchy_commands.py` indexing Omarchy's 100+ native tools (`omarchy screenshot`, `omarchy audio`, `omarchy theme`, `omarchy weather`, `omarchy toggle nightlight`) directly into the root search view.
  - **Instant Multi-Modal View**: Renders real Omarchy screenshot images, code snippets, color swatches, and links with filter tabs (`[All]`, `[📌 Pinned]`, `[📄 Text]`, `[ Code]`, `[🎨 Colors]`, `[🌐 Links]`, `[🖼️ Images]`).

---

## 3. Architectural Decision Records (ADRs)

### ADR 011: Omarchy-Native State & CLI Reuse
* **Status**: Accepted
* **Context**: Reimplementing clipboard watchers and system services in Python created unnecessary duplication and desync with Omarchy's built-in daemons.
* **Decision**: Omnicast directly leverages Omarchy's existing state files (`clipboard-history.json`, `colors.toml`) and command catalog (`omarchy commands --json`), focusing its engine entirely on delivering Raycast's unmatched UI/UX, navigation stack, and Action Palette.

---

## 4. Current Working State

* **System Status**: Manhattan taken (2026-10-24). Omarchy-first hardening then OPR (not AUR). AI deferred; Omarchy-LLM out of band (ADR 015).
* **Live hotkey**: `ALT + SPACE` → `bin/omnicast`
* **Snippets**: in-launcher only (`SnippetsView` + `snippet_manager.py`). Global expander daemon removed.
* **Site**: https://omnicast.best
* **File search / preview (2026-09-05, branch `koustav`)**: typed Files in root (`fd` + scopes), selection-follow side preview, colored markdown/code HTML, OnlyOffice-aware open, content search opt-in via `content:` only (keeps name search fast).

### File search: saved backlog (do not lose)

**Optional polish (not required now)**
- Richer highlight via pygments (optional dep)
- PDF multi-page browse
- Image zoom / pan
- Deduplicate same basename across folders more smartly
- Remember last file scope
- Tiny “no results in this scope” empty state

**Still behind Raycast (file loop)**
1. Content search as a first-class, fast index: not only opt-in `content:` over a live `rg` scan
2. Richer Quick Look: PDF/Office thumbnails, media scrubbing, smoother type coverage
3. Search scopes UX: saved scopes, ignore rules, UI to manage them (we have cycle + `in:`)
4. Actions depth: duplicate, Quicklink, AI attach, etc.
5. Years of edge-case polish: weird encodings, huge trees, permissions, network mounts

**Not behind on the idea**: in-pane reading, OnlyOffice-aware open, Omarchy feel, blazing name search.

### ADR 012: Exec + Paths singletons
* **Status**: Accepted
* **Decision**: Use `Quickshell.shellDir` + `Quickshell.execDetached` via `Paths`/`Exec` singletons; ban new `createQmlObject(Process)` and absolute home paths.

### ADR 013: Shell-level HUD panel
* **Status**: Accepted
* **Decision**: `HudPanel` is a separate layer-shell window so feedback survives launcher dismiss.

### ADR 014: Omarchy umbrella (not Raycast clone)
* **Status**: Accepted
* **Context**: Reimplementing Omarchy-owned surfaces (clipboard especially) produced worse UX than the native plugins. Raycast-shaped chrome also felt foreign next to Omarchy menu/clipboard/emoji.
* **Decision**:
  1. **Handoff** tools Omarchy already ships (`omarchy-menu-*`, `omarchy menu summon <route>`, shell overlays): dismiss Omnicast first, then launch.
  2. **Own** only the umbrella brain: root search, frecency/favorites, scripts/forms, calc, and true gaps (snippets/WM palette; AI later).
  3. **Visual language** matches Omarchy `[launcher]`/`[menu]` tokens from `~/.local/state/omarchy/current/theme/shell.toml` + Hyprland rounding: not Raycast aesthetics.
* **Consequences**: Faster daily-driver path; less duplicate code; Omnicast identity = “beautiful front door to Omarchy.”

### ADR 015: Manhattan without AI; Omarchy-LLM out of band
* **Status**: Accepted (2026-09-05)
* **Context**: Closing Manhattan on real AI (and a from-scratch Omarchy LLM) would delay the non-AI daily loop. A custom ultra-light Omarchy model is a separate research mission.
* **Decision**:
  1. **Manhattan** = finish non-AI handoff / own / curate tools only. Mock Ask AI may remain.
  2. **Real AI gateway** (Ollama/BYOK) is deferred until after Manhattan; optional Berlin+.
  3. **Omarchy-LLM** is not an Omnicast milestone and must not block or reshape M4-M6 planning.
* **Consequences**: Clear build order; AI research can proceed in another track without coupling.

### ADR 016: Extension strategy (scripts-first; never Raycast Store clone)
* **Status**: Accepted (2026-10-24)
* **Context**: Berlin needs a clear extensibility story. Cloning Raycast’s React extension API / Store is a multi-year trap and fights Omarchy’s CLI culture. Vicinae already competes on Store-compat.
* **Decision**:
  1. **Tier 0 (now):** Script Commands in `~/.config/omnicast/commands/` with `@raycast.*` / `@omarchy.*` frontmatter (see `docs/script-commands.md`).
  2. **Tier 1 (Berlin):** Deeplinks (`omnicast://…`) so Hyprland binds and external tools can summon search, views, and snaps without a plugin SDK.
  3. **Tier 2 (later):** Index / handoff community packages from the Omarchy plugin registry ([omarchyplugins.com](https://omarchyplugins.com)); prefer “open native plugin” over re-hosting.
  4. **Never:** full Raycast Store / React extension host inside Omnicast as a goal.
* **Consequences**: Extensions stay shell-native and reviewable; Omnicast stays the umbrella, not an app store.

### ADR 017: Hyprland float snaps as Berlin killer workflow
* **Status**: Accepted (2026-10-24)
* **Context**: Raycast window management is approximate (Accessibility). Omarchy Hyprland exposes exact Lua `hl.dsp.window.*` geometry.
* **Decision:** Ship `window_snap.py` presets (halves, thirds, quarters, center, maximize) as Omnicast-owned actions + `omnicast snap <preset>` / `omnicast://snap?layout=…` for binds. Prefer Lua dispatch; never classic `setfloating` batches.
* **Consequences:** A workflow that is objectively better than Raycast Free WM on this OS.