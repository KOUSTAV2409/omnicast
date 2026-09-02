# Master Roadmap: Omnicast (Raycast for Omarchy & Linux)

> **Document Type:** Execution Master Plan & Milestone Tracker  
> **Status:** Phases 1, 2, 3, 4, and 5 Complete | Moving to Phase 6 (AI Assistant Gateway)  

---

## Progress Overview

| Phase | Description | Status | Deliverables |
| :--- | :--- | :--- | :--- |
| **Phase 0** | **System Blueprint & Knowledge Base Setup** | 🟢 Done | Comprehensive Specs & LLM Memory |
| **Phase 1** | **Core UI/UX Engine & Shell Window (Quickshell)** | 🟢 Done | Base Window, Searchbar, Design Tokens, Blur, IPC |
| **Phase 2** | **Navigation Stack & Action Palette Engine** | 🟢 Done | Push/Pop Views, Breadcrumb Trail, Action Sheet |
| **Phase 3** | **Declarative View Primitives (List+Detail, Grid, Forms)** | 🟢 Done | Markdown Split-view, Grid layouts, Argument Forms |
| **Phase 4** | **Power Tools Suite (Clipboard, Snippets, Window)** | 🟢 Done | SQLite Clipboard, Dynamic Expander, Hyprland IPC |
| **Phase 5** | **Script Commands & Extension Engine** | 🟢 Done | Parser for `@omarchy.*` / `@raycast.*` scripts |
| **Phase 6** | **AI Assistant & Streaming Chat View** | 🟡 Next | Modular LLM Gateway, Streaming Tokens, Custom Prompt Presets |

---

## Detailed Milestone Status

### Phase 1: Core UI Engine & Glassmorphism Window (🟢 Complete)
- [x] Implemented `OmnicastWindow.qml` with Wayland Layer-Shell overlay.
- [x] Integrated `Theme.qml` singleton with live Omarchy `colors.toml` parser.
- [x] Built `SearchBar.qml` with search icon, clear button, and breadcrumb tags.
- [x] Built `FooterBar.qml` with dynamic primary/secondary action shortcut pills.
- [x] Built `ActionPalette.qml` (`Ctrl+K`) floating context menu with action search.
- [x] Built `bin/omnicast` CLI wrapper with Quickshell IPC daemonization.

### Phase 2: Navigation Stack & Action Palette Engine (🟢 Complete)
- [x] Implemented `NavigationStack.qml` with smooth push/pop opacity & slide transitions.
- [x] Dynamic breadcrumbs in `SearchBar` tracking navigation depth.
- [x] Wired `Esc` key navigation: pops sub-views before dismissing window.
- [x] Universal `Ctrl+K` action sheets per sub-view.

### Phase 3: Declarative View Primitives (🟢 Complete)
- [x] `DetailPane.qml`: Rich Markdown document viewer + metadata key-value table.
- [x] `ListDetailView.qml`: Two-column split layout (44% list, 56% detail pane).
- [x] `GridView.qml` & `GridCard.qml`: Visual card grid with 2D keyboard navigation (`←`, `→`, `↑`, `↓`).
- [x] `FormView.qml`: Dynamic parameter collection form with field focus navigation.

### Phase 4: Native Power Tools (🟢 Complete)
- [x] **SQLite Clipboard Daemon**: `src/backend/clipboard_manager.py` with content-type classification (text, code, color, url) and search.
- [x] **Dynamic Snippet Expander**: `src/backend/snippet_manager.py` with variable replacements (`{date}`, `{time}`, `{clipboard}`, `{uuid}`).
- [x] **Hyprland Workspace & Window Dispatcher**: Instant socket2 dispatching (`movewindow`, `fullscreen`, `togglefloating`).
- [x] **Omarchy Theming Integration**: Live theme switching via `omarchy theme set` in `ThemePickerView.qml`.

### Phase 5: Script Command Runner & Extensibility (🟢 Complete)
- [x] **Frontmatter Parser**: `src/backend/script_runner.py` parsing `@omarchy.*` and `@raycast.*` metadata headers.
- [x] **Dynamic Argument Forms**: Automatically generates `FormView` inputs when scripts declare arguments.
- [x] **Script Output Viewer**: `ScriptResultView.qml` rendering script output in formatted Markdown.
- [x] **Built-in Scripts Library**: Sample scripts created (`system-info.sh`, `ip-lookup.sh`).

### Phase 6: AI Assist & Automation Gateway (🟡 Next)
- [ ] Connect `AiAssistView.qml` to local/remote LLM backend with streaming token callbacks.
- [ ] Implement quick context-actions: "Explain Selection", "Summarize", "Generate Script".
