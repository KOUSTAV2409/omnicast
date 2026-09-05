# Raycast Features vs Omarchy Built-Ins

> **Document type:** Crosswalk for the Omnicast **umbrella** doctrine (ADR 014)  
> **Date:** 2026-09-04  
> **Sources:** [`research.md`](../research.md) · [`docs/spec/raycast-feature-matrix.md`](spec/raycast-feature-matrix.md) · `/usr/share/omarchy` (shell plugins, `omarchy-menu*`, default Hyprland binds)

---

## 0. Verdict

Raycast’s product is **one key → one brain → many tools**.

Omarchy already ships a large share of those tools: clipboard, emoji, system menu, themes, capture, share, reminders, image picker, Hyprland helpers, agents: but as **siblings**: separate overlays, CLIs, and keybinds.

**Omnicast’s job** is not to reimplement them. It is to be the **unified searchable front door** that either:

| Role | Meaning |
| :--- | :--- |
| **Handoff** | Dismiss Omnicast → open the native Omarchy surface (`omarchy-menu-*`, shell plugin, menu route) |
| **Own** | Feature Omarchy does not provide as a Raycast-like integrated tool |
| **Curate** | Index many small Omarchy/Hyprland commands into one searchable list |
| **Gap** | Neither side has a strong equivalent yet |

---

## 1. How Omarchy surfaces tools today

### Shell plugins (`omarchy-shell` overlays)

| Plugin id | Role |
| :--- | :--- |
| `omarchy.menu` | Hierarchical system / apps / style / capture / share menu |
| `omarchy.clipboard` | Clipboard history overlay |
| `omarchy.emojis` | Emoji picker overlay |
| `omarchy.image-picker` | Image grid picker |
| `omarchy.notifications` | Notification center |
| `omarchy.reminders` | Reminders |
| `omarchy.lock` / `omarchy.polkit` | Lock & auth |
| `omarchy.agents` | Agent-related shell UI |
| `omarchy.bar` / `omarchy.osd` / `omarchy.background` | Desktop chrome (not launcher tools) |
| `omarchy.panels` | Hardware / network / etc. panels |

### Menu entrypoints (individual binaries)

| Command | Opens |
| :--- | :--- |
| `omarchy-menu` / `omarchy-menu toggle [route]` | System menu (root, apps, system, capture, share, theme, …) |
| `omarchy-menu-clipboard` | Clipboard plugin |
| `omarchy-menu-emoji` | Emoji plugin |
| `omarchy-menu-images` | Image picker |
| `omarchy-menu-file` | File picker (label + paths + formats) |
| `omarchy-menu-keybindings` | Keybind cheatsheet |
| `omarchy-menu-share` | Share flows |
| `omarchy-menu-timezone` | Timezone picker |

### Default hotkeys (Omarchy Hyprland defaults)

| Bind | Tool |
| :--- | :--- |
| `Super+Space` | Omarchy menu |
| `Super+Alt+Space` | Apps menu |
| `Super+Ctrl+V` | Clipboard manager |
| `Super+Ctrl+E` | Emojis |
| `Super+Ctrl+C` | Capture menu |
| `Super+Ctrl+S` | Share menu |
| `Super+Ctrl+R` | Reminder |
| `Super+Ctrl+Space` | Background switcher |
| `Super+Shift+Ctrl+Space` | Theme menu |
| `Super+K` | Keybindings |
| `Super+Escape` | System / power menu |

Omnicast stays on **`Alt+Space`** so it does not steal Super+Space.

---

## 2. Full crosswalk (Raycast → Omarchy → Omnicast)

### 2.1 Core launcher & search

| Raycast | Omarchy (individual) | Omnicast role |
| :--- | :--- | :--- |
| Root Search (apps, commands, extensions) | `omarchy.menu` apps + providers; not a Raycast-style unified root | **Own** umbrella search |
| File Search (inline / indexed) | `omarchy-menu-file`, `omarchy-file-select`, Nautilus launchers | **Handoff** / later thin FTS |
| Quicklinks | No first-party URL bookmark system | **Own** |
| Calculator / units / colors | No first-party calc | **Own** (root eval) |
| Fallback commands (e.g. Quick AI) | - | **Own** later |
| Favorites / aliases / frecency | Menu has aliases in JSONC; no launcher frecency | **Own** ranking |

### 2.2 UI grammar (chrome)

| Raycast | Omarchy | Omnicast role |
| :--- | :--- | :--- |
| Search bar + list / detail / grid / form | Each overlay has its own chrome (`Color.menu`, `Style`) | **Match Omarchy tokens**: do not clone Raycast look |
| Action Panel (`⌘K`) | Per-surface key handlers | **Own** light Action Panel for Omnicast-owned views |
| HUD / toast | OSD / notifications plugins | **Own** small HUD for Omnicast actions; else rely on Omarchy |
| Navigation stack | Menu nav stack inside `omarchy.menu` | **Own** only inside Omnicast-owned views |

### 2.3 Power tools

| Raycast | Omarchy equivalent(s) | Default access | Omnicast role |
| :--- | :--- | :--- | :--- |
| **Clipboard History** | `omarchy.clipboard`, `omarchy-clipboard-paste-*` | `Super+Ctrl+V` | **Handoff** |
| **Emoji & Symbols** | `omarchy.emojis`, `omarchy-menu-emoji` | `Super+Ctrl+E` | **Handoff** |
| **Window Management** | `omarchy-hyprland-window-*`, layout toggles, gaps, width, pop | Scattered binds/CLIs | **Curate** searchable palette (or handoff each) |
| **Switch Windows** | `omarchy-hyprland-focus-app`, `omarchy-launch-or-focus*` | CLI / menu | **Curate** in search |
| **Snippets** | - | - | **Own** |
| **File Search** | `omarchy-menu-file`, file select | Menu / scripts | **Handoff** |
| **Image / screenshot browse** | `omarchy.image-picker`, `omarchy-menu-images`, capture cmds | Menu / bind | **Handoff** |
| **Screenshots / recording** | `omarchy-capture-*`, menu Capture | `Super+Ctrl+C`, Print flows | **Handoff** via catalog |
| **System commands** | Menu System (lock/suspend/reboot/…), powerprofiles | `Super+Escape` | **Handoff** |
| **Audio / Bluetooth / Network** | `omarchy-audio-*`, bluetooth bins, panels | Bar + hardware menu | **Handoff** / catalog |
| **Themes** | `omarchy-theme-*`, menu `style.theme` | Theme menu bind | **Handoff** |
| **Wallpaper** | `omarchy-theme-bg-*`, menu background | `Super+Ctrl+Space` | **Handoff** |
| **Notes** | - | - | **Gap** |
| **Calendar** | - | - | **Gap** |
| **Translator** | - | - | **Gap** |
| **Focus / pomodoro** | Reminders adjacent only | - | **Gap** / weak handoff to reminders |
| **Reminders** | `omarchy.reminders`, `omarchy-reminder` | `Super+Ctrl+R` | **Handoff** |
| **Share sheet** | `omarchy-menu-share` | `Super+Ctrl+S` | **Handoff** |
| **Keybinding reference** | `omarchy-menu-keybindings` (+ tmux/herdr) | `Super+K` | **Handoff** |
| **Notifications center** | `omarchy.notifications` | Bar / shell | Don’t rebuild |

### 2.4 AI

| Raycast | Omarchy | Omnicast role |
| :--- | :--- | :--- |
| Quick AI / AI Chat / Commands | Not a Raycast-style Quick AI | **Own** (local/BYOK): Phase D |
| Screen Awareness | Capture + agent crash/diagnose flows | Partial **Curate** |
| Agents / MCP-ish | `omarchy-agent*`, agents plugin, usage CLIs | **Handoff** + catalog |
| Dictation | fcitx / IME (not Raycast dictation) | **Gap** |

### 2.5 Extensibility

| Raycast | Omarchy | Omnicast role |
| :--- | :--- | :--- |
| Script Commands | Ad-hoc scripts; menu JSONC actions | **Own** frontmatter runner |
| Extension Store | Themes/plugins via Omarchy + [omarchyplugins.com](https://omarchyplugins.com) | **Curate later (Berlin)**: index/handoff community Omarchy plugins in root search; not a Raycast Store clone |
| Deeplinks | Shell IPC (`omarchy-shell …`) | Later: Omnicast IPC + handoff |
| Cloud Sync | - | **Gap** (local-first by design) |

---

## 3. Summary counts (heuristic)

| Bucket | Approx. Raycast power areas | Implication |
| :--- | ---: | :--- |
| **Handoff-ready** (strong Omarchy tool) | Clipboard, emoji, menu/system, theme, wallpaper, capture, share, reminders, images, keybindings, notifications, agents | Wire via `Exec.omarchy*`: never re-UI |
| **Curate** (many small Omarchy CLIs) | Window/focus/layout, audio/BT, install/remove/update menu tree | Index `omarchy` catalog + hypr helpers in root search |
| **Own** (true gaps for umbrella UX) | Unified root + ranking, calc, snippets, quicklinks, script commands, Quick AI | Build inside Omnicast |
| **Gap / later** | Notes, calendar, translator, dictation, cloud sync, Store | Only if daily-driver demand appears |

---

## 4. Implementation rule (ADR 014)

Before adding any new Omnicast view for a Raycast-like feature:

1. Search `/usr/share/omarchy/bin` and `shell/plugins` for an existing surface.
2. If it exists and feels good → **handoff** (`requestDismiss` + `Exec.omarchy…`).
3. If Omarchy has only fragmented CLIs → **curate** into root search / a thin list that still calls those CLIs.
4. If nothing exists → **own** it, styled with Omarchy `[launcher]` / `[menu]` tokens: not Raycast aesthetics.

---

## 5. Related docs

- [`research.md`](../research.md): full Raycast inventory  
- [`docs/spec/raycast-feature-matrix.md`](spec/raycast-feature-matrix.md): older parity matrix (partially superseded by umbrella doctrine)  
- [`memory.md`](../memory.md): ADR 014  
- [`implementation-plan.md`](../implementation-plan.md): execution plan  
