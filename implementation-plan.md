# Omnicast Implementation Plan

> **Document type:** Master execution plan (Manhattan → Berlin)  
> **Date:** 2026-09-04  
> **Based on:** [`research.md`](research.md) · [`analysis.md`](analysis.md) · current `src/`  
> **Doctrine:** Omnicast is the **Omarchy umbrella**: one beautiful entry that searches and either handoffs to native Omarchy surfaces or fills true gaps. Match Omarchy menu/launcher UX tokens; do **not** clone Raycast chrome. (ADR 014)

---

## 0. Honest baseline

| Claim in `roadmap.md` | Reality (`analysis.md`) |
|---|---|
| Phases 1-5 ✅ Done | Skeleton + one strong surface (clipboard). Many P0 contracts unfinished or broken. |
| Phase 6 = next | Correct for AI: but **Critical bugs and P0 UX gaps must land before/alongside AI**. |

**What already works well (keep / polish):**
- Layer-shell window, Esc ladder, Search → List → Footer → Ctrl+K grammar
- Omarchy clipboard bridge (multimodal, pin, paste)
- Omarchy command catalog + theme apply + theme colors.toml sync
- Script frontmatter scan (partial)
- Hyprland dispatch entry points

**What blocks “feels like Raycast”:**
- Broken script args, no HUD, no ranking/favorites/aliases, fake AI, no global snippets, Process/`createQmlObject` chaos, hardcoded machine paths

**Definition of Manhattan done:** A Raycast power user on Omarchy can do launch → clipboard → snippet expand → window tile → script → calc → web fallback without missing muscle memory (Enter / Ctrl+K / Esc), with HUD confirmation and smart ranking. **Ask AI is not required** for Manhattan (may stay mocked).

**Definition of Berlin done:** At least three workflows feel *better* than Raycast because of Hyprland/Omarchy (deep tiling, free unlimited clipboard/themes, local AI default, `omarchy` as OS API).

---

## 1. Guiding principles (from research)

1. **Hero workflows > feature checklist**: Clipboard, snippets, WM, scripts, calc, AI first.
2. **Fix contracts before features**: Broken Form→script and silent `wtype` failures destroy trust.
3. **Paint UI first**: Never flash empty while scanners run; drive `SearchBar.busy`.
4. **One Process helper**: Kill `Qt.createQmlObject(Process…)` sprawl; typed runner with paths relative to the repo/install.
5. **Dogfood daily**: Every phase must leave Alt+Space usable (Flare failure mode).
6. **Docs track code**: Update `roadmap.md` / specs when pivoting (SQLite → Omarchy).
7. **Vicinae is the competitive floor**: Watch it; don’t copy blindly; win on Omarchy fusion + polish.

---

## 2. Workstream map

```
WS-A  Foundation & reliability     (Critical bugs, paths, Process helper, dead code)
WS-B  Raycast interaction grammar  (HUD, ranking, Action Panel, Form contract, loading)
WS-C  Power tools depth            (Snippets expand, WM, calc, Quicklinks, scripts modes)
WS-D  Search surface               (File search, emoji, empty-state favorites)
WS-E  AI gateway                   (Real streaming; Ollama/BYOK)
WS-F  Platform & Berlin            (Deeplinks, dmenu interop, Hyprland layouts, store strategy)
```

Phases below sequence these workstreams so each milestone is shippable.

---

## 3. Phased plan

### Phase A: Stabilize the prototype (1-2 weeks)
**Goal:** Installable, no Critical bugs, honest docs. Daily driver doesn’t lie.

| ID | Task | Files / notes | Done when |
|---|---|---|---|
| A1 | **Resolve backend path** once (env / `Quickshell.shellDir` / `OMNICAST_ROOT`): remove all `/home/iamkxyz/Projects/omnicast/...` hardcodes | All views + Process commands | Works from any clone path |
| A2 | **Fix `ScriptResultView` args**: append `scriptArgs` to `script_runner.py exec` | `ScriptResultView.qml`, `script_runner.py` | Form → script receives argv |
| A3 | **Honor script `mode`**: `silent` (run + HUD, no push), `compact` (toast/HUD result), `fullOutput` (current), `inline` (root row refresh later) | `script_runner.py`, `RootSearchView.qml` | Modes match Raycast semantics |
| A4 | Introduce **`ProcessRunner.qml` / `exec.sh` helper**: replace `createQmlObject(Process)` for launch, wl-copy, hyprctl, python backends | New helper; migrate RootSearch, Clipboard, Snippets, WM, Theme, AI | No new createQmlObject Process |
| A5 | **Clipboard pin/delete race**: await Process finish then reload; or optimistic UI | `ClipboardView.qml` | Pin/unpin reflects immediately & correctly |
| A6 | **FormView view contract**: `executeCurrent` = submit; Tab field nav; stop SearchBar filter stealing form focus when on Form | `FormView.qml`, `OmnicastWindow.qml` | Args forms usable by keyboard only |
| A7 | Cleanup: remove or quarantine **dead** `clipboard_manager.py`, `services/NavStack.qml`; fix `navStack` prop wiring | backends, services, `OmnicastWindow.qml` | No dead exports; analysis smells gone |
| A8 | **Doc sync**: rewrite `roadmap.md` status to match analysis; note ADR 011 clipboard path in feature matrix | `roadmap.md`, `docs/spec/*` | Agents stop building SQLite daemon |
| A9 | Strip personal email from default snippets; detect terminal via `$TERMINAL` / omarchy | `snippet_manager.py`, `RootSearchView`, `app_indexer.py` | Portable defaults |

**Exit criteria:** Script args work; no absolute paths; silent/fullOutput modes work; pin works; Form submits with Enter; roadmap honest.

---

### Phase B: Raycast interaction parity (2-3 weeks)
**Goal:** Muscle memory matches research Appendix A P0.

| ID | Task | Notes | Done when |
|---|---|---|---|
| B1 | **HUD layer**: transient layer-shell or in-window pill: Copied / Pasted / Theme applied / Script done / Failed | New `Hud.qml` + IPC; dismiss launcher then show | Every primary side-effect shows feedback |
| B2 | **Toast** inside window for async errors (script fail, AI error) with Copy Error | Per Raycast feedback API | Errors aren’t silent |
| B3 | Drive **`SearchBar.busy`** during scanners / clipboard load; never show EmptyState while loading | RootSearch, Clipboard | No empty flash |
| B4 | **Frecency store** (`~/.local/share/omnicast/ranking.json`): bump on execute; rank root results | New small backend or QML JSON | Frequent cmds rise |
| B5 | **Favorites + aliases**: pin section at empty query; alias match beats fuzzy; Action Panel “Add to Favorites” / “Set Alias” | Config JSON | Empty root = Favorites → Recent → Power Tools |
| B6 | **Fuzzy search** (simple subsequence / fzf-like) for Root + Action Panel + ListDetail | Shared util | `slk` → Slack-class matching feel |
| B7 | **Action Panel upgrade**: sections, destructive style, fuzzy, submenu stub for Configure | `ActionPalette.qml` | Closer to Raycast ⌘K |
| B8 | Footer **primary label** from selected item (`primaryActionTitle` field) not coarse heuristics | Item model + FooterBar | Clipboard shows “Paste”, etc. |
| B9 | Color swatches in DetailPane; fix ThemePicker current theme detection; use **GridView** for themes | DetailPane, ThemePicker | Visual parity for colors/themes |

**Exit criteria:** Open → act → HUD; favorites/frecency noticeable; Action Panel searchable & sectioned; no loading flicker.

---

### Phase C: Power tools depth (2-4 weeks)
**Goal:** Daily hero workflows at Raycast Free-tier depth (research §2.3).

| ID | Task | Notes | Done when |
|---|---|---|---|
| C1 | **Global snippet expander**: background listener (keywords) + `wtype`/`ydotool` with settings for delay; disable inside password fields if possible | New daemon or Quickshell service | Typing `:shrug` expands in Foot/Ghostty |
| C2 | Snippet CRUD in UI (create/edit/delete/import); Espanso/JSON import later | SnippetsView + manager | No hand-editing JSON required |
| C3 | **Quicklinks**: JSON config; `{argument}` / `{clipboard}` placeholders; root search section | New view + backend | Param URL bookmarks work |
| C4 | **Calculator v2**: units, simple currency (static/API), dates; color `#hex` → formats row | RootSearch | Matches Raycast calculator usefulness |
| C5 | **Window Management v2**: halves/thirds/quarters, center, float, fullscreen, move monitor/workspace; fix hyprctl arity; remove empty 33% stub; optional “layout from current” (Berlin later) | WindowTilerView | Raycast WM free-tier parity on Hyprland |
| C6 | Script library growth + docs for `~/.config/omnicast/commands`; honor `needsConfirmation` | docs + samples | Users can add scripts without reading source |
| C7 | Clipboard polish: keyboard category switch (`Ctrl+P` style); plain-text paste action; paste-fail HUD | ClipboardView | Matches Raycast clipboard habits |

**Exit criteria:** Snippet expand works system-wide; Quicklinks + stronger WM + calc in daily use; scripts feel Raycast-compatible.

---

### Phase D: AI gateway (1-2 weeks, can overlap late C)
**Goal:** Replace mock; local-first (Berlin advantage: no Pro paywall for basic AI).

| ID | Task | Notes | Done when |
|---|---|---|---|
| D1 | **LLM backend**: Python streaming client: Ollama default, OpenAI-compatible BYOK | New `ai_gateway.py` | Tokens stream into DetailPane |
| D2 | Wire `AiAssistView`: cancel, model picker, error toast; presets as commands | AiAssistView | No Timer mock |
| D3 | **Quick AI in Root**: if query looks like a question / fallback when no matches | RootSearch | Ask without opening AI view |
| D4 | Context actions: Explain selection / Summarize clipboard (read `wl-paste` / selection if available) | AI + clipboard | “Ask Clipboard” analogue |
| D5 | Settings for endpoint/model/API key under `~/.config/omnicast/ai.json` | Config | User can switch providers |

**Exit criteria:** Real streaming AI from Alt+Space; Ollama works offline; BYOK optional.

---

### Phase E: Search surface expansion (2-3 weeks)
**Goal:** Root Search absorbs files & emoji (Raycast v2 pillars).

| ID | Task | Notes | Done when |
|---|---|---|---|
| E1 | **File search** provider: `fd`/`plocate` or simple index; show in Root when query looks like path/name | New backend | Files appear beside apps |
| E2 | **Emoji & Symbols** grid view; optional `:` inline later | GridView finally earns keep | Insert emoji via wtype/wl-copy |
| E3 | App indexer: freedesktop icons, GenericName/Keywords, respect OnlyShowIn/Hidden | app_indexer.py | Icons look native |
| E4 | Fallback commands setting (Quick AI, file search, web search) | Config | No-match still useful |
| E5 | Compact mode (optional P2): search-only until type | OmnicastWindow | Matches Raycast v2 polish |

**Exit criteria:** Files + emoji in daily loop; app rows look first-party.

---

### Phase F: Berlin & platform (ongoing after Manhattan)
**Goal:** Beat Raycast where Omarchy allows; avoid Flare’s fate.

| ID | Task | Notes |
|---|---|---|
| F1 | Deeplinks `omnicast://command?...` + Copy Deeplink action | Automation / Hyprland binds |
| F2 | Hyprland **layout capture** / named layouts (better than Raycast Accessibility WM) | Berlin wedge |
| F3 | dmenu/stdin mode for Rofi interop (Walker lesson) | Linux credibility |
| F4 | Extension strategy decision: **script-first forever** vs Raycast-compat (Vicinae path) vs own API: write ADR | Don’t stall on Store early |
| F5 | Optional MCP tools for AI (after D) | Match Raycast frontier selectively |
| F6 | Packaging: AUR / omarchy plugin path; Hyprland `layerrule` blur docs | Install ≠ clone repo |
| F7 | Competitive dogfood vs Vicinae monthly | Stay honest about gaps |

---

## 4. Suggested sequencing (calendar view)

```
Week 1-2   Phase A  Stabilize
Week 3-5   Phase B  Interaction parity (HUD + ranking + Action Panel)
Week 5-8   Phase C  Power tools (snippets expand + WM + Quicklinks + calc)
Week 7-9   Phase D  AI (overlap late C)
Week 9-12  Phase E  Files + emoji
Week 12+   Phase F  Berlin / packaging / extension ADR
```

Adjust if dogfooding reveals a broken hero path: **always prioritize trust (A/B) over new surfaces (E/F)**.

---

## 5. Milestone checklists

### M1: “Trustworthy prototype” (= Phase A exit)
- [x] No hardcoded home paths
- [x] Script args + modes work
- [x] Process helper (`Exec` / `Paths`) in place for new code
- [x] Clipboard pin reliable (await mutator)
- [x] Form keyboard-complete (`interceptsSearch`, Tab, Enter submit)
- [x] Roadmap/spec match code

### M2: “Feels like Raycast chrome” (= Phase B exit)
- [x] HUD on copy/paste/theme/script (`Hud` + `HudPanel`)
- [x] Favorites + frecency + aliases store (`Ranking`)
- [x] Fuzzy search (`Fuzzy`)
- [x] Action Panel fuzzy + destructive styling
- [x] Loading bar (`SearchBar.busy`), accurate footer labels (`primaryActionTitle`)

### M3: “Daily driver Free-tier” (= Phase C exit)
- [x] Global snippet expansion (`bin/omnicast-snippetd` + evdev best-effort)
- [x] Quicklinks (`quicklinks.py` + root section)
- [x] WM halves/thirds/quarters
- [x] Calc units/colors
- [x] Clipboard keyboard filters (`Ctrl+P` cycle) + plain-text paste

### M4: “AI-native launcher” (= Phase D exit): **DEFERRED**
- [ ] Streaming Ollama/BYOK
- [ ] Quick AI fallback (root / no-match → real model)
- [ ] Clipboard/selection context actions (explain / summarize)
*(Not required for Manhattan. Not Omarchy-LLM. Revisit after M5.)*

### M5: “Manhattan complete” (non-AI umbrella)
- [x] Handoff Omarchy-strong tools (clipboard, emoji, theme, images, menu, capture, share, reminders, keybindings)
- [x] Own calc / quicklinks / scripts / ranking / snippets surface
- [x] Curate Hyprland + `omarchy-hyprland-*` into searchable Windows palette + root index
- [x] No-match fallbacks (web search; Ask AI stub OK)
- [x] File search handoff (`Find Files` → omarchy-file-select)
- [x] Snippetd reliability (delay/backend settings, wtype/ydotool, failure notify/HUD)
- [x] Calc depth (currency approx + dates)
- [ ] Non-AI dogfood pass: close remaining handoff/own/curate gaps from the crosswalk
- [ ] Declare Manhattan taken (without real AI)

**Manhattan daily loop (umbrella):** Alt+Space → apps/commands/calc → handoff clipboard/emoji/theme/files → Windows pop/float/gaps → scripts/quicklinks/snippets → web fallback → Esc.

### M6: “Berlin underway” (= Phase F)
- [ ] Packaging / install path
- [ ] Deeplinks (`omnicast://…`)
- [ ] One Hyprland-only workflow clearly better than Raycast
- [ ] Extension strategy ADR accepted
- [ ] Optional: generic AI gateway (Ollama/BYOK): still separate from Omarchy-LLM

Plain-language backlog: [`roadmap.md`](roadmap.md) → **What’s left to build**.

---

## 6. Explicit non-goals (until after M5)

- Full React extension Store / Raycast API compatibility (unless ADR says otherwise)
- Cloud sync / Teams / Enterprise
- Dictation / Focus / Calendar / Notes (Raycast Pro adjacent: optional Berlin+)
- Matching every Store extension (Linear/Slack/…): use scripts + omarchy + browser for now
- Rewriting UI in Tauri/Electron (stay Quickshell)
- **Shipping real AI to close Manhattan**
- **Omarchy-LLM** (ultra-light custom model): separate mission; not an Omnicast milestone

---

## 7. Risk register

| Risk | Mitigation |
|---|---|
| Wayland snippet/`wtype` unreliable | Settings for delay; HUD on failure; document ydotool fallback |
| Scope creep vs Vicinae | Manhattan checklist only until M5; weekly “ship something dogfoodable” |
| Process latency × N | Cache scan results (done for root catalogs); optional long-lived Python sidecar later |
| Single-maintainer burnout | Prefer scripts over Store; small phases; delete dead code early |
| Doc drift repeats | Keep `roadmap.md` “What’s left” in sync with this §5 |
| Custom LLM distracts Manhattan | ADR 015: Omarchy-LLM is out of band |

---

## 8. Immediate next actions (start here)

1. **Non-AI dogfood**: run the Manhattan daily loop; file gaps against the crosswalk  
2. **Close non-AI gaps**: handoff / own / curate only (no model work)  
3. **Declare M5** when the loop is trustworthy without Ask AI  
4. **Berlin** packaging / plugins; optional generic AI gateway later  
5. **Never** schedule Omarchy-LLM inside Omnicast M4-M6

Do not start Store / Pro-adjacent surfaces before M5. Do not block M5 on AI.

---

## 9. Document upkeep

| Doc | Owner cadence |
|---|---|
| `analysis.md` | Re-audit at each milestone exit |
| `implementation-plan.md` | Check off IDs; revise estimates monthly |
| `roadmap.md` | Status + **What’s left to build** (human-facing backlog) |
| `research.md` §8 | Update parity table as items ship |
| `memory.md` | New ADRs (Process helper, ranking store, extension strategy, AI gateway) |

---

*This plan supersedes the “Phase 6 only” narrative in the old roadmap. Manhattan is Phases A-E; Berlin is Phase F.*
