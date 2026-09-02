# Project Memory: Omnicast

> **Document Type:** Living Memory, Architectural Decision Records (ADRs), Lessons Learned & Project State  
> **Concept:** Agent Wiki / Continuous LLM Knowledge Base (Karpathy Pattern)  
> **Status:** Active  
> **Last Synchronized:** 2026-09-02  

---

## 1. Project Invariants & Guiding Laws

Whenever any agent or developer touches this project, the following rules MUST be upheld:

1. **Aesthetic Parity**: Never sacrifice visual elegance for expediency. Every view must include subtle borders, balanced padding, readable font hierarchies, active-selection accents, and smooth transitions.
2. **The `Ctrl+K` Contract**: Every selectable item in every view MUST have a primary action (`Enter`) and an Action Palette trigger (`Ctrl+K` or `Tab`) with context-aware secondary operations.
3. **Layer-Shell Protocol Compliance**: The UI must be implemented as a Wayland overlay window using `wlr-layer-shell` with exclusive keyboard focus while active, and instant dismiss on `Esc` or background click.
4. **Omarchy Skill Rules**: Do NOT hardcode file changes into `/usr/share/omarchy/`. All user configs and custom modules must respect Omarchy's userland directory structure in `~/.config/omarchy/` and `~/.config/hypr/`.
5. **System Keybinding Contract**:
   - `SUPER + SPACE`: Preserved for standard Omarchy System Menu.
   - `ALT + SPACE`: Bound globally to Omnicast (`~/Projects/omnicast/bin/omnicast`).

---

## 2. Chronological Milestones & Event Log

### [2026-09-02] - End-to-End System Scrutiny & Deep Audit
- **Audit Findings & Fixes**:
  - **Dynamic Application Indexing**: Replaced static app list with `src/backend/app_indexer.py` which dynamically scans `.desktop` files in `/usr/share/applications` and `~/.local/share/applications`, extracting accurate exec paths, category badges, and contextual icons.
  - **Instant Math Calculator**: Integrated live arithmetic expression evaluator into `RootSearchView.qml` (`24 * 1024`, `500 / 4`, `sqrt(144)` immediately yields `= result` as the top item with ↵ copy).
  - **Continuous Clipboard Watcher**: Embedded a persistent `wl-paste --watch` process in `src/shell.qml` to capture every copy event across the OS automatically into SQLite.
  - **Live Theme Synchronization**: Added live `colors.toml` watcher in `src/services/Theme.qml` for real-time color updates across all views when `omarchy theme set` is called.

### [2026-09-02] - Global System Keybinding Activated: `ALT + SPACE`
- **Milestone**: Configured `ALT + SPACE` in `~/.config/hypr/bindings.lua` to trigger Omnicast with zero conflicts.

### [2026-09-02] - Phase 4 & 5 Complete: Power Tools Suite & Script Command Engine
- **Milestone**: Engineered the persistent SQLite clipboard history database, dynamic snippet template expander, and full Raycast-compatible script command engine with dynamic argument forms.

### [2026-09-02] - Phase 2 & 3 Complete: Navigation Stack & Declarative View Primitives
- **Milestone**: Engineered the hierarchical Push/Pop Navigation Stack and the complete suite of declarative Raycast-parity UI primitives.

### [2026-09-02] - Phase 1 Complete: Core UI Engine & Glassmorphism Window
- **Milestone**: Successfully built and tested the base Quickshell overlay window with Raycast-grade aesthetics.

---

## 3. Architectural Decision Records (ADRs)

### ADR 009: Live Math Expression Evaluator
* **Status**: Accepted
* **Context**: Raycast allows instant inline calculations in the search bar.
* **Decision**: Integrated a safe AST math evaluator directly into `RootSearchView.qml` that dynamically detects arithmetic patterns and renders an instant `= result` delegate with single-keystroke copy to clipboard.

### ADR 010: Dynamic Desktop Application Indexer
* **Status**: Accepted
* **Context**: Need automatic discovery of all installed desktop apps with custom terminal wrapping and icon categorization.
* **Decision**: Built `src/backend/app_indexer.py` scanning standard XDG and user desktop directories.

---

## 4. Current Working State

* **System Status**: Fully operational, audited, verified, and running on `ALT + SPACE`.
