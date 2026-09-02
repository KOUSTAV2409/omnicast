# Raycast Feature Matrix & Linux Parity Specification

> **Document Type:** Feature Parity Audit & Implementation Strategy  
> **Reference System:** Raycast (macOS) vs. Omnicast (Omarchy / Linux)  

---

## 1. UI & Layout Primitives

| Raycast Feature | Description | Omnicast Implementation Strategy | Priority |
| :--- | :--- | :--- | :--- |
| **Search Input Bar** | Instant debounced search with accessory pills, clear button, and prefix search | Quickshell `TextInput` with custom styling and filter tags | P0 |
| **List View** | Sections, items with icon, title, subtitle, badges, accessories | QML `ListView` with custom item delegates and section headers | P0 |
| **List + Detail View** | Left list selection + Right markdown document viewer & metadata key-value table | QML `SplitView` with `TextEdit` (Markdown format) + Metadata Component | P0 |
| **Grid View** | Card grid for visual browsing (icons, wallpapers, files) | QML `GridView` with responsive cell sizing and aspect ratios | P1 |
| **Form View** | Dynamic form generator for parameter inputs | Dynamic QML loader rendering fields based on JSON/metadata schema | P1 |
| **Action Panel (`Ctrl+K`)** | Context-sensitive secondary action menu | Floating nested palette component with categorized action groups | P0 |
| **Push/Pop Stack** | Hierarchical navigation history with back navigation on `Esc` | QML `StackView` with smooth sliding/fade transitions | P0 |
| **Breadcrumb Bar** | Path indicator of current nested navigation level | Breadcrumb pill component at top right of search area | P1 |
| **Footer & Hotkey Bar** | Dynamic bar showing primary action and hotkey combinations | Sticky bottom bar bound to currently focused view and selected item | P0 |
| **HUD / Toasts** | Floating pill for instant user feedback ("Copied", "Saved") | Dedicated transient layer-shell HUD notification widget | P1 |

---

## 2. Core Built-In Power Tools

| Tool | Raycast Capability | Omnicast Architecture |
| :--- | :--- | :--- |
| **Clipboard History** | Search text, code snippets, hex swatches, images; direct paste into active app | `wl-paste` capture daemon writing to SQLite database with full-text search (`FTS5`); direct paste via `wtype` / `ydotool` |
| **Snippet Expander** | Dynamic keyword expansion (`:date`, `:shrug`) with template variables | Background key-combo listener + replacement engine with variable parser |
| **Window Management** | Tile left/right half, center, maximize, throw to monitor/workspace | Direct `hyprctl dispatch` IPC commands for instantaneous Hyprland control |
| **Script Commands** | Execute Bash, Python, Node scripts with frontmatter metadata | Parser for `~/.config/omarchy/omnicast/commands/` parsing `@omarchy.*` headers |
| **Quicklinks** | Parametrized URL bookmarks with query variable prompting | JSON-configured quicklinks opening in default browser with query injection |
| **System Commands** | Sleep, Lock, Shutdown, Reboot, Volume/Brightness, Audio device select | Native integration with `omarchy` commands and `systemd` / `wireplumber` |
| **Floating Scratchpad** | Persistent quick markdown notes accessible globally | SQLite/Markdown file backed note editor floating overlay |
| **AI Assistant** | Inline streaming chat, grammar correction, code explanations, refactoring | Modular LLM backend (OpenAI/Anthropic/Gemini/Ollama) with streaming UI |

---

## 3. Extensibility & Extension Architecture

| Area | Raycast Spec | Omnicast Equivalent |
| :--- | :--- | :--- |
| **Metadata Format** | Frontmatter comments in script files | Compatible `@omarchy.*` & `@raycast.*` metadata comments |
| **Execution Modes** | `fullOutput`, `compact`, `silent`, `inline` | Supported across all runner types |
| **Supported Languages** | Bash, Zsh, Python, Node, Ruby, Swift | Any executable script with a shebang (`#!/usr/bin/env ...`) |
| **Dynamic Arguments** | `@raycast.argument1 { "type": "text", "placeholder": "..." }` | Auto-generates inline inputs or Form Views before script invocation |
