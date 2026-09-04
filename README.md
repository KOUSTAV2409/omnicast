# Omnicast 🚀

> **Raycast-grade command engine, visual productivity launcher, and extension platform for Omarchy and Wayland Linux.**

Omnicast brings the unmatched aesthetics, fluid micro-interactions, keyboard-first navigation stack, and extensible power-tools of **Raycast** natively to **Omarchy (Hyprland + Quickshell)**.

---

## 🌟 Key Highlights

- ✨ **Raycast-Level Polish**: Frosted glassmorphism, hardware-accelerated fluid animations, crisp typography, and Omarchy theme synchronization.
- ⌨️ **Keyboard-First Workflow**: Push/pop view stacks, `Ctrl+K` Action Palette, breadcrumbs, and instant key navigation.
- 📑 **Declarative Views**: List, Rich Split Markdown Details, Visual Grids, and Dynamic Argument Forms.
- 🧰 **Built-In Power Tools**:
  - 📋 Universal Clipboard History (Text, Code, Hex Swatches, Images).
  - ⚡ Dynamic Snippet Expander with variable templating.
  - 🪟 Hyprland Window Management & Workspace Dispatcher.
  - 🤖 Streaming AI Assistant & Contextual Presets.
- 🔌 **Extensible Script Commands**: Run Bash, Python, and Node scripts with familiar `@omarchy.*` / `@raycast.*` metadata headers.

---

## 📚 Agent / LLM Knowledge Base & Wiki

This project is organized following the **LLM Wiki / Agent Knowledge Base** architecture:

- [`context.md`](context.md) — Ground-truth product context, system constraints, and architectural vision.
- [`memory.md`](memory.md) — Living project memory, Architectural Decision Records (ADRs), invariants, and lessons learned.
- [`research.md`](research.md) — Independent Raycast product / UX / clones research (Manhattan bar).
- [`analysis.md`](analysis.md) — Current Omnicast codebase audit & gap analysis.
- [`implementation-plan.md`](implementation-plan.md) — Authoritative Manhattan → Berlin execution plan.
- [`roadmap.md`](roadmap.md) — High-level status pointer (mirrors implementation plan milestones).
- [`docs/spec/raycast-feature-matrix.md`](docs/spec/raycast-feature-matrix.md) — Comprehensive Raycast parity audit.
- [`docs/raycast-vs-omarchy.md`](docs/raycast-vs-omarchy.md) — Raycast features ↔ Omarchy built-in tools crosswalk (umbrella doctrine).
- [`docs/spec/ui-ux-design-system.md`](docs/spec/ui-ux-design-system.md) — Exact design tokens, layer-shell rules, and interaction curves.

---

## 🛠️ Tech Stack

- **Compositor**: Hyprland (Wayland)
- **UI Engine**: Quickshell (Qt6 / QML)
- **Host OS**: Omarchy 4.0.2 (Arch Linux)
- **IPC Protocols**: `wlr-layer-shell`, Hyprland UNIX Sockets, SQLite FTS5

---

## 🚀 Getting Started

See [`implementation-plan.md`](implementation-plan.md) for the active plan. Start at **Phase A** (stabilize). Context: [`analysis.md`](analysis.md) · [`research.md`](research.md).
