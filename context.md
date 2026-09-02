# Project Context: Omnicast (Raycast for Omarchy & Linux)

> **Document Type:** Agent & LLM Knowledge Base / Core Context  
> **Target Audience:** AI Agents (Pair Programmers, Subagents) & Human Developers  
> **Status:** Active / Foundation Phase  
> **Last Updated:** 2026-09-02  

---

## 1. Executive Summary & Vision

**Omnicast** is a next-generation, keyboard-first command engine, productivity launcher, and extension platform built natively for **Omarchy** and the modern **Wayland / Linux desktop**.

Unlike conventional Linux application launchers (e.g., Rofi, Wofi, dmenu) which are limited to fuzzy string matching and single-action execution, Omnicast bridges the gap to the standard set by **Raycast (macOS)**:
1. **Unmatched Visual Polish & Micro-Interactions**: Hardware-accelerated fluid transitions, acrylic/Kawase background blur, crisp typography, and responsive breadcrumb stacks.
2. **The Dynamic Interaction Model**: Hierarchical Push/Pop navigation views, secondary Action Sheets (`Ctrl+K`), rich List+Detail split views with live Markdown rendering, Form inputs, and Grid visual views.
3. **End-to-End Power Tools**: Universal Clipboard History (text/images/colors), dynamic Snippet text expansion, Script Commands with metadata headers, Hyprland window tiling, and streaming AI assistance.
4. **Deep System Synergy**: Native integration with Omarchy's global theming system, Quickshell (Qt/QML), Hyprland IPC sockets, and Wayland Layer-Shell protocols.

---

## 2. Core Philosophy & Non-Negotiables

1. **Aesthetics & UX are Tier-1 Requirements**: Visual excellence is not an afterthought. Layouts, border radiuses, shadows, padding, debounce intervals, and animation curves must feel premium and instantaneous.
2. **Keyboard-First, Zero Mouse Dependency**: Every view, action, form, and dialog must be fully operable via keyboard shortcuts with clear footer hotkey discoverability.
3. **Deep OS & WM Integration**: Native to Hyprland and Omarchy. Inherit active color schemes (`omarchy theme`), utilize `wlr-layer-shell` overlays, and bind directly to window management events.
4. **Extensibility Without Bloat**: Support lightweight script commands in any language (Bash, Python, Node, Rust) through simple frontmatter headers (`@omarchy.*` / `@raycast.*` metadata).
5. **Deterministic State & Zero Latency**: Fast boot times, instant search debounce (<10ms), and reactive data binding without UI stuttering.

---

## 3. Host Environment & System Profile

* **Host OS**: Omarchy 4.0.2 (Arch Linux rolling base)
* **Kernel**: Linux 7.1.9-arch1-2
* **Display Server / Protocol**: Wayland (`wlr-layer-shell`)
* **Compositor**: Hyprland 0.56.2 (GPU-accelerated, native Kawase blur, bezier animations)
* **Shell Engine**: Quickshell (Qt6 / QML Wayland desktop shell engine)
* **Terminal Ecosystem**: Ghostty, Alacritty, Foot, Kitty
* **Environment Managers**: `mise` (polyglot runtime manager), `pacman` + `yay` (AUR)

---

## 4. Key Architectural Decisions (ADR Summary)

| Domain | Decision | Rationale |
| :--- | :--- | :--- |
| **UI Engine** | **Quickshell (QML / QtQuick)** | Native Wayland layer-shell support, hardware-accelerated rendering at high refresh rates (up to 144Hz), dynamic property binding, and seamless integration with existing Omarchy shell components. |
| **Backend / Daemon** | **Lightweight Node/Python/Rust IPC Service** | Handles clipboard SQLite storage, global hotkey triggers, snippet keyword expansion, and background script command discovery. |
| **Window Protocol** | **`zwlr_layer_shell_v1` (Overlay Layer)** | Allows keyboard grab, overlay positioning above all tiled windows, and background blur via Hyprland layer rules. |
| **Theme Sync** | **Omarchy Theme Engine Bridge** | Listens to `~/.config/omarchy/themes/` and live updates colors across all UI components on theme change hooks. |

---

## 5. Directory Structure & Knowledge Base Layout

```
/home/iamkxyz/Projects/omnicast/
├── context.md                    # THIS FILE: Ground-level context & system architecture
├── memory.md                     # Living project memory, ADRs, milestones & lessons
├── roadmap.md                    # Multi-phase execution roadmap & feature tracking
├── README.md                     # High-level overview & developer onboarding
├── docs/
│   ├── spec/                     # Detailed technical specifications
│   │   ├── raycast-feature-matrix.md
│   │   ├── ui-ux-design-system.md
│   │   └── script-command-api.md
│   └── wiki/                     # LLM / Agent knowledge base deep dives
└── src/                          # Source code (QML, shell scripts, backend daemons)
```
