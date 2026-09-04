# Omnicast Current-State Analysis

> **Document type:** Codebase audit & gap analysis vs Raycast (Manhattan bar)  
> **Date:** 2026-09-04  
> **Inputs:** Full `src/` audit · [`research.md`](research.md) §8–§9 · [`roadmap.md`](roadmap.md) · ADR 011 in [`memory.md`](memory.md)  
> **Companion:** [`implementation-plan.md`](implementation-plan.md)

**Scope:** `/home/iamkxyz/Projects/omnicast` (docs + all of `src/`, `bin/`, `commands/`)  
**Date:** 2026-09-04  
**Lens:** research.md §8 Manhattan checklist + Appendix A P0/P1  
**Verdict:** Strong Omarchy-native shell skeleton with real power-tool surfaces; **not Manhattan-ready**. Docs overstate completion (roadmap Phases 4–5 “Done”); several critical wiring bugs and P0 gaps remain.

---

## 1. Project posture (docs vs code)

| Source | Claims | Reality |
|---|---|---|
| `roadmap.md` | Phases 1–5 complete; Phase 6 next | UI primitives exist; clipboard is Omarchy JSON (not SQLite FTS5); AI is a timer mock; Grid unused; script modes ignored |
| `memory.md` / ADR 011 | Omarchy-native fusion | Matches live path (`omarchy_clipboard.py`, `omarchy_commands.py`) |
| `docs/spec/raycast-feature-matrix.md` | SQLite clipboard, FTS5, snippet daemon | Spec drift — live code abandoned SQLite for Omarchy state |
| `research.md` §8 | Partial Action Panel, no HUD, mock AI, manager-only snippets | Accurate |

**Stack size:** ~4.3k LOC across ~30 source files. Thin but dense; quality issues are architectural/wiring, not missing files alone.

---

## 2. Area-by-area audit

### 2.1 Shell entry — `bin/omnicast`, `src/shell.qml`, `src/OmnicastWindow.qml`

**Exists / works**
- Layer-shell overlay (`WlrLayer.Overlay`, exclusive keyboard when visible).
- IPC `toggle` / `show` / `dismiss` / `ping` via Quickshell `IpcHandler`.
- Layout zones: Search → NavigationStack → Footer; ActionPalette overlay.
- Esc ladder: palette → pop → dismiss; click-outside dismiss.
- Search delegates filter / execute / action palette / ↑↓ to current view.

**Bugs / rough edges**
- `pushSubViewWithProps` sets `props.navStack = root.navStack`, but `PanelWindow` has **no** `navStack` property (only an id). Views always get `navStack: undefined`. Harmless today only because nothing uses it.
- Signal connects on each push for ActionPalette/Dismiss only; nested views that need `requestPushView` must emit through RootSearchView closures (fragile).
- `NavigationStack.reset()` keeps root view; reopen reuses stale RootSearchView (OK for cache, bad if indexes should refresh).
- Fixed 760×480 card; no compact mode, no size scale (P1/P2).
- No real backdrop blur wiring visible in QML (relies on Hyprland layer rules externally — undocumented here).
- Footer Esc “Back/Close” is **display-only** (no click handler).

**Missing vs P0/P1**
- HUD/toast after dismiss (P0).
- Paint-UI-first / `isLoading` (SearchBar has unused `busy`).
- Compact mode (P2).

**Smells**
- Hardcoded geometry; no settings surface.

---

### 2.2 Components

#### `ActionPalette.qml`
**Works:** Overlay, mini search, ↑↓/↵/Esc, shortcut pills, opacity/scale.  
**Gaps:** Substring `.includes` only (not fuzzy); no sections, submenus (`…`), destructive styling, “Configure Hotkey/Alias” actions (P0 Action Panel gaps).  
**Smell:** `cursorShape: PointingHandCursor` vs Appendix P2 “no web pointer.”

#### `SearchBar.qml`
**Works:** Icon, breadcrumbs, clear, key grammar (↑↓, ↵, Esc, Tab/Ctrl+K).  
**Gaps:** Placeholder promises “files…” with no file search; `busy` never driven; no inline ≤3 args; no filter accessory dropdown (P1).

#### `FooterBar.qml`
**Works:** Primary label + Actions ⌃K + Esc hint.  
**Gaps:** Primary text heuristic in `OmnicastWindow` is coarse (`Applications` / Theme / Script / else “Select”); deep views (clipboard Paste, AI Copy) often wrong. Esc row not clickable.

#### `NavigationStack.qml`
**Works:** push/pop/reset, opacity fade, destroy on pop.  
**Smells:** Transitions via `Qt.createQmlObject(NumberAnimation…)` (same anti-pattern as Process spawning); no slide; no StackView.

#### `ListDetailView.qml` + `DetailPane.qml` + `ItemRow.qml` + `EmptyState.qml`
**Works:** 44/56 split, selection wrap, markdown + metadata, section headers in root list, empty states.  
**Gaps:** DetailPane has image but **no color swatch** from `item.color` (clipboard/theme lose visual parity); EmptyState has no CTA; no accessories beyond badge/shortcut; no `isLoading` skeleton.

#### `FormView.qml`
**Works:** Text/password/toggle UI, submit button.  
**Broken / incomplete:**
- Does **not** implement view contract (`filter` / `moveSelection` / `executeCurrent` / `openActionPalette`) → SearchBar ↵ may not submit.
- No Tab between fields; dropdown type declared in comments but unimplemented.
- Focus stays on SearchBar; form inputs fight global search focus.
- `onFormSubmitted` wired from RootSearchView props — works only if createObject signal handler binding succeeds.

#### `GridView.qml` / `GridCard.qml`
**Status:** Implemented, registered in `qmldir`, **never used by any view**. Theme picker uses ListDetail instead of grid (missed visual win). Horizontal/vertical move APIs not wired to SearchBar (only ±1 via `moveSelection`).

---

### 2.3 Services

#### `Theme.qml` (singleton)
**Works:** Reads `~/.local/state/omarchy/current/theme/colors.toml`; maps accent/backgrounds; `reloadTheme()`.  
**Rough:** Polls every **3s** (`Timer`) instead of file watch; `cardBackground` stays near-opaque hardcoded rgba (won’t track light themes well); font stack defaults to **Inter** (generic).  
**Smell:** Spawns `cat` via Process each poll.

#### `NavStack.qml` (services)
**Dead code.** Real stack is `components/NavigationStack.qml`. Duplicate mental model; qmldir still exports it.

---

### 2.4 Views

#### `RootSearchView.qml` (~488 LOC — god object)
**Works:**
- Sections: Power Tools, Omarchy cmds, Scripts, Apps.
- Parallel Process scanners for scripts / omarchy / apps.
- Calculator for simple arithmetic; copy via `wl-copy`.
- Script → Form → Result push path (intended).
- Action lists per item; EmptyState on no match.

**Bugs / incomplete wiring**
- **Hardcoded** `/home/iamkxyz/Projects/omnicast/src/backend/*.py` in three Process commands — not portable.
- Ubiquitous `Qt.createQmlObject('…Process…')` for launch/copy/terminal — no lifecycle, leak risk, shell-injection surface on routes/exec strings.
- Terminal hardcodes **`ghostty`**.
- Search is **substring**, not fuzzy; **no frecency, favorites, aliases, Reset Ranking** (P0).
- Empty root shows full catalog (power tools + potentially 100+ omarchy + all apps) — no “recent / favorites first” empty state; will feel heavy.
- No loading UI while three Python processes run → empty flash risk (P0 #7).
- Math via `Function('"use strict"; return (' + sanitized + ')')()` — charset-limited but still eval-shaped.
- `omarchy` `route` vs `exec` field unused inconsistently (`route` used for shell).

**Missing vs P0/P1:** frecency/aliases/favorites; file search; quicklinks; emoji; deeplinks; fallback commands; paint-first loading.

#### `ClipboardView.qml` + `omarchy_clipboard.py`
**Strongest feature.**
- Category tabs; List+Detail; pin/delete; paste via `wl-copy` + `wtype`; URL/`imv` actions; color/code/url/image classification; Omarchy `clipboard-history.json` + local pin file.

**Bugs**
- Pin/delete: fire Process then **immediate** `reloadData()` → race (stale UI).
- Content with newlines/quotes still shell-escaped for `wl-copy` via `sh -c` — fragile for large/binary-adjacent text.
- Hardcoded python path again.
- Filter tabs mouse-only (no keyboard category switch — P1 accessory gap).
- Orphan: `clipboard_manager.py` (SQLite, ~388 LOC) **unused** after ADR pivot — roadmap still claims SQLite.

#### `SnippetsView.qml` + `snippet_manager.py`
**Works:** List+Detail, insert (wl-copy + `wtype`), copy, template vars `{date,time,uuid,clipboard}`.  
**P0 gap:** **No global keyword expansion** — manager-only (research §8).  
**Smells:** Default snippet embeds personal email `iamkxyz@gmail.com`; insert may type into launcher if dismiss timing wrong; no CRUD UI (JSON file only).

#### `WindowTilerView.qml`
**Works:** Few hyprctl actions with markdown detail.  
**Bugs:** `hyprctl dispatch` with single string `"movewindow l"` may be wrong arity; **“Tile Left (33%)” callback is empty**; no thirds/quarters/custom layouts/monitor throw (P1). Uses ListDetail, not interactive window picker.

#### `ThemePickerView.qml`
**Works:** `omarchy theme set` + Theme.reload.  
**Bugs:** Seeds hardcoded list including forcing **Eventide as current** (`name === "Eventide"`); then async `omarchy theme list` may overwrite; not using GridView despite color cards existing; no dismiss/HUD after apply.

#### `ScriptResultView.qml` + `script_runner.py`
**Works:** Scan `@omarchy.*` / `@raycast.*`; exec with timeout; markdown result; re-run / copy.  
**Critical bug:** `scriptArgs` property is set from FormView path but **never appended to Process command** — argument forms are non-functional.  
**Gaps:** `mode` parsed (`fullOutput|compact|silent|inline`) but **never honored** — always full result view; silent/inline/compact missing (P0). Timeout 15s hard. Sample scripts only (2).

#### `AiAssistView.qml`
**Mock only.** 600ms `Timer` returns canned markdown (“Antigravity LLM Stream”). Presets are mouse chips; own TextInput fights SearchBar focus; no streaming, no Ollama/BYOK, no selection context. Roadmap Phase 6 correctly “Next”; research marks P0 for Manhattan AI loop.

---

### 2.5 Backends (`src/backend/*.py`)

| File | Role | Status |
|---|---|---|
| `omarchy_clipboard.py` | Live clipboard bridge | Active, solid classification |
| `omarchy_commands.py` | `omarchy commands --json` | Active; hides `hidden`; title heuristics OK |
| `app_indexer.py` | `.desktop` index | Active; emoji icons not theme icons; ghostty for Terminal=true; no keywords/GenericName search depth |
| `script_runner.py` | Scan/exec | Active; modes unused by UI; mkdir empty user dir on scan |
| `snippet_manager.py` | Snippets JSON | Active; no daemon |
| `clipboard_manager.py` | SQLite clipboard | **Dead / duplicate** of pre-pivot design |

No long-lived daemon; every action is one-shot Process from QML. No FTS5 despite context.md / matrix claims.

---

### 2.6 Commands & launcher

- `src/commands/system-info.sh`, `ip-lookup.sh` — valid frontmatter demos.
- `bin/omnicast` — IPC toggle then `-n -d` spawn; `sleep 0.25` racey on slow starts; path derived from script location (good) unlike QML hardcoded backends.

---

## 3. Architecture assessment

### Strengths (Omarchy-native approach)
- **Correct wedge:** Reuse Omarchy clipboard JSON, `omarchy` CLI catalog, theme `colors.toml`, Hyprland dispatch — matches ADR 011 and Berlin advantages in research §9.
- **Right UI engine:** Quickshell layer-shell + exclusive grab fits Wayland better than Tauri/WebView clones.
- **Interaction grammar scaffold:** Search / List+Detail / Form / Ctrl+K / Esc ladder / footer — the Raycast skeleton is present.
- **Clipboard multimodal UI** is already above typical Rofi-class Linux launchers.

### Fragility
- **Process-as-IPC:** Every backend call and side effect is `python3` / `sh -c` / `createQmlObject(Process)`. No shared service, no typed IPC, no cancellation, races on pin/reload, startup latency ×3 scanners.
- **Hardcoded absolute paths** to one developer machine break installability.
- **Shell string assembly** for routes, clipboard content, markdown copy — injection and breakage under real content.
- **Doc/spec drift** (SQLite vs Omarchy, Phase “Done”) will mislead agents into building the wrong layer.
- **Duplicate artifacts** (`NavStack` vs `NavigationStack`, `clipboard_manager` vs `omarchy_clipboard`) signal incomplete pivot cleanup.
- **God-object RootSearchView** concentrates indexing, ranking, calc, scripting, and process orchestration — hard to harden or test.
- **Wayland input** (`wtype`) is best-effort with `|| true` — paste/snippet reliability opaque; no HUD confirmation when it fails (compounding P0 feedback gap).

---

## 4. Manhattan P0/P1 gap matrix (code-validated)

| Capability | Priority | Code status | Notes |
|---|---|---|---|
| Root Search + sections | P0 | Partial | Sections yes; no frecency/aliases/favorites |
| Action Panel searchable | P0 | Partial | Exists; weak filter; no sections/submenus/config actions |
| Footer primary + Actions | P0 | Present | Labels often wrong for deep views |
| List / List+Detail / Grid / Form | P0 | Partial | Grid unused; Form incomplete |
| Esc ladder | P0 | Wired | OK |
| HUD / Toast | P0 | **Missing** | |
| Clipboard | P0 | Strong | Race on pin/delete |
| Snippets in-app expand | P0 | Manager only | No global expander |
| Script modes | P0 | Partial | Parser only; **args not passed** |
| AI Quick + Chat | P0 | Mock timer | |
| Paint UI first / isLoading | P0 | Missing | `busy` unused |
| Frecency ranking | P0 | Missing | |
| Calculator | P1 | Basic | No units/currency/dates |
| Window management | P1 | Basic | Stub 33%; few layouts |
| Themes | P1 | Works | Hardcoded “current” quirk |
| Quicklinks | P1 | Missing | |
| File Search | P1 | Missing | |
| Emoji/Symbols | P1 | Missing | |
| Deeplinks | P1 | Missing | |
| Compact mode | P2 | Missing | |
| Inline ≤3 args in search | P1 | Missing | Forms only (and broken args) |

---

## 5. Ranked issue list

### Critical
1. **`ScriptResultView` ignores `scriptArgs`** — Form → script path is broken (`ScriptResultView.qml` Process command only passes path).
2. **Hardcoded `/home/iamkxyz/Projects/omnicast/...` backend paths** in RootSearch, Clipboard, Snippets, ScriptResult — non-portable.
3. **No HUD/toast** after paste/copy/theme/script — P0 feedback; failures of `wtype` are silent.
4. **AI is fake** — Phase 6 UI implies real product; Manhattan daily loop unmet.

### High
5. **`Qt.createQmlObject(Process…)` everywhere** — lifecycle leaks, no error handling, shell injection risk.
6. **No frecency / favorites / aliases** — Root Search won’t feel like Raycast.
7. **Script `mode` not honored** (silent/compact/inline).
8. **Snippets: no global keyword expansion** (P0).
9. **Pin/delete race** in ClipboardView (reload before Process finishes).
10. **FormView missing view contract + focus fight** with SearchBar; dropdown unimplemented.
11. **Substring-only search** (Action Panel + Root + ListDetail).
12. **Roadmap/spec claim SQLite clipboard Done** while live path is Omarchy JSON; dead `clipboard_manager.py` confuses maintainers.

### Medium
13. **`services/NavStack.qml` dead**; `root.navStack` assignment broken/undefined.
14. **GridView unused**; ThemePicker should be grid + real current theme detection (Eventide hardcode).
15. **Window tiler stubs** (empty 33% action); weak hyprctl argument packing.
16. **Theme poll every 3s** instead of watch; Inter default font.
17. **Terminal hardcoded to ghostty** in RootSearch + app_indexer.
18. **Footer primary labels** inaccurate for clipboard/AI/snippets.
19. **Empty root dumps entire catalog** — no recent/favorites-first.
20. **Personal email in default snippets**.
21. **Calculator** eval-shaped; limited operators; no unit/currency.
22. **App indexer** emoji icons, not freedesktop icons; incomplete desktop key handling (`OnlyShowIn`, etc.).

### Low
23. Footer Esc not clickable; PointingHand cursors (P2 Linux feel).
24. Navigation transitions via createQmlObject; no slide.
25. SearchBar placeholder mentions files; no file search.
26. Duplicate color/HEX helpers across clipboard backends.
27. `bin/omnicast` fixed `sleep 0.25` race.
28. Sample script library size (2); no user docs for `~/.config/omnicast/commands`.
29. AiAssist preset chips overflow risk on narrow width; mouse-first.
30. Markdown detail truncates content (2000–2500 chars) without “show more.”

---

## 6. Code smell summary (concrete)

| Smell | Where |
|---|---|
| Absolute home path | `RootSearchView.qml`, `ClipboardView.qml`, `SnippetsView.qml`, `ScriptResultView.qml` |
| `createQmlObject` Process / Animation | Most views + `NavigationStack.qml` |
| Mock AI `Timer` 600ms | `AiAssistView.qml` |
| Dead SQLite clipboard | `clipboard_manager.py` |
| Dead NavStack service | `services/NavStack.qml` |
| Unused Grid | `GridView.qml` / `GridCard.qml` |
| Unused `SearchBar.busy` | loading bar never shown |
| Hardcoded Eventide “current” | `ThemePickerView.qml` |
| Hardcoded ghostty | `RootSearchView.qml`, `app_indexer.py` |
| Personal email default | `snippet_manager.py` |
| God-object root search | `RootSearchView.qml` |
| 3s theme poll | `Theme.qml` |

---

## 7. Bottom line

Omnicast has a **credible Raycast-shaped shell** and a **genuinely strong Omarchy clipboard integration**, which is the right product bet. What blocks Manhattan is not missing QML files — it is **unfinished contracts** (script args/modes, HUD, ranking, real AI), **process-spawning fragility**, and **docs that mark Phase 4–5 complete while critical paths are partial or broken**. Treat the current tree as a high-fidelity prototype with one production-grade surface (clipboard), not a parity-complete launcher.