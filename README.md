# Omnicast

> First we take Manhattan, then we take Berlin.

**Alt+Space for Omarchy**: one launcher that searches your machine and either **hands off** to native Omarchy tools or **owns** the gaps they don’t cover.

Not a Raycast UI clone. An **Omarchy umbrella**: same muscle memory as a modern launcher, styled like Omarchy’s menu/clipboard surfaces, wired into Hyprland and the Omarchy CLI.

**Site:** [omnicast.best](https://omnicast.best) · **News:** [omnicast.best/news](https://omnicast.best/news/) · **Code:** [github.com/KOUSTAV2409/omnicast](https://github.com/KOUSTAV2409/omnicast)

> **Not affiliated with [omarchy.org](https://omarchy.org).** Independent community project that intends to earn a place in that ecosystem.

### Tell your agent

Paste this to Cursor / Claude / ChatGPT on an Omarchy machine:

```text
Set up Omnicast on this Omarchy box:
Run: curl -fsSL https://omnicast.best/install | bash
```

---

## Quick start (Omarchy only)

**Needs:** Omarchy (Hyprland) + Quickshell (`qs` on PATH).

### One-line installer (Recommended)

```bash
curl -fsSL https://omnicast.best/install | bash
```

*Or via GitHub raw:*
```bash
curl -fsSL https://raw.githubusercontent.com/KOUSTAV2409/omnicast/main/install.sh | bash
```

The installer automatically:
1. Clones to `~/.local/share/omnicast`
2. Symlinks `omnicast` to `~/.local/bin/omnicast`
3. Registers `ALT + SPACE` in `~/.config/hypr/bindings.lua` (keeping `SUPER + SPACE` for the Omarchy menu)
4. Adds the desktop entry and populates sample script commands in `~/.config/omnicast/commands/`

---

### Manual Clone (Developers)

```bash
git clone https://github.com/KOUSTAV2409/omnicast.git
cd omnicast
./bin/omnicast
```

Bind `Alt+Space` in `~/.config/hypr/bindings.lua`:
```lua
o.bind("ALT + SPACE", "Omnicast", os.getenv("HOME") .. "/omnicast/bin/omnicast")
```

### Optional

```bash
# Global snippet expander (python-evdev + membership in `input` group)
./bin/omnicast-snippetd
```

Script commands: drop executables in `~/.config/omnicast/commands/`. See [`docs/script-commands.md`](docs/script-commands.md).

**Stuck?** [Open an issue](https://github.com/KOUSTAV2409/omnicast/issues). Feedback from Raycast → Omarchy users is especially welcome.

---

## What you get today

### One entry point
| | |
|---|---|
| Hotkey | **Alt+Space** → `bin/omnicast` |
| Super+Space | Left for the native Omarchy menu |
| Search | Fuzzy match + frecency, favorites, aliases |
| Chrome | Search → list → footer · **Enter** primary · **Ctrl+K** actions · **Esc** dismiss |
| Look | Omarchy `[menu]` / `[launcher]` tokens, Hyprland rounding |

### Handoff (Omarchy already does this well)
Omnicast dismisses and opens the native surface:

- Clipboard history  
- Emoji picker  
- Theme & background  
- Images / screenshots browser  
- **Find Files** (portal picker → open)  
- Keybindings viewer  
- System menu, capture, share, reminders  

### Own (Omnicast fills the gap)
- **Apps & commands**: `.desktop` apps + Omarchy CLI catalog  
  - Try: `foot`, `screenshot`, `nightlight` (→ Omarchy: Toggle Nightlight)
- **File search**: type a name → Files section (`fd` + content via `rg`) under a scope (`home` / `projects` / …)  
  - Try: a folder/file name · Enter opens · **Ctrl+K → Full Preview** to peek
  - `content:phrase` finds inside files (slower) · `in:projects foo` scopes · **Ctrl+Shift+P** cycles scope
  - Ctrl+K: Full Preview · Copy Path · Reveal
- **Calculator**: math, `#hex` colors, units, rough FX (verify on Google), dates  
  - Try: `12*7+3` · `#ff8800` · `10 km to mi` · `10 usd to inr` (shows ≈ guess + Google live rate) · `days until 2026-12-25`
- **Quicklinks**: bookmarks with `{argument}` / `{clipboard}` placeholders  
  - Try: open **Quicklinks**, or search a link title you saved
- **Script commands**: Raycast-style frontmatter (`@raycast.*` / `@omarchy.*`), form args, `silent` / `compact` / `fullOutput`  
  - Drop scripts in `~/.config/omnicast/commands/`. See [`docs/script-commands.md`](docs/script-commands.md)
- **Snippets**: manage + optional global expander (`bin/omnicast-snippetd`)  
  - Try: open **Snippets**, or type a keyword like `:shrug` if snippetd is running  
  - Settings: `~/.config/omnicast/snippetd.json` → `{ "delay_ms": 150, "backend": "auto" }` (`wtype` / `ydotool`)
- **Windows**: curated Omarchy Hyprland helpers (pop, gaps, transparency, layout) + Lua-safe float/fullscreen  
  - Try: `pop`, `gaps`, `float`, or open **Windows**
- **Fallbacks**: no match → Search Web or Ask AI  
  - Try: type nonsense → **Search Web** / **Ask AI** rows appear

### Not ready yet
- **AI**: UI stub only; **deferred** (not required for Manhattan). Custom Omarchy-LLM is a separate mission outside this repo.  
- **Packaged install**: clone-and-run for now (AUR / plugin path later)

Full Raycast ↔ Omarchy map: [`docs/raycast-vs-omarchy.md`](docs/raycast-vs-omarchy.md)

---

## Stack

| Layer | Choice |
|---|---|
| OS | Omarchy (Arch) |
| Compositor | Hyprland (Wayland) |
| UI | Quickshell (Qt6 / QML), `wlr-layer-shell` |
| Glue | Omarchy CLI + state, `hyprctl` Lua dispatch |

---

## Repo map

| Path | Role |
|---|---|
| [`bin/omnicast`](bin/omnicast) | Launch / IPC toggle |
| [`src/`](src/) | Shell, views, services, backends |
| [`docs/work-order.md`](docs/work-order.md) | Ordered next actions (Manhattan non-AI) |
| [`site/`](site/) | Public landing + news |
| [`docs/script-commands.md`](docs/script-commands.md) | Script command API |
| [`docs/raycast-vs-omarchy.md`](docs/raycast-vs-omarchy.md) | Feature crosswalk |
| [`implementation-plan.md`](implementation-plan.md) | Manhattan → Berlin plan |
| [`roadmap.md`](roadmap.md) | Status snapshot |
| [`memory.md`](memory.md) | ADRs (incl. umbrella doctrine) |
| [`context.md`](context.md) | Agent / product context |

---

## Status

**Manhattan (non-AI umbrella):** close remaining handoff/own/curate gaps, then declare taken **without** shipping real AI.  

**Next:** non-AI dogfood + gap close. AI gateway and Omarchy-LLM are out of band. Public site: [omnicast.best](https://omnicast.best).

Full leftover backlog: [`roadmap.md`](roadmap.md) → **What’s left to build**.

---

## Security (local desktop)

Omnicast is a **local** Alt+Space launcher. Cloning it from GitHub does **not** give anyone remote access to your machine. It runs as your user, like a browser or editor.

Hardening includes: secrets/session paths blocked from search & preview, owner-only cache (`0600`), no shell launch of desktop `Exec=` lines, script commands only from allowlisted folders, and no executing `.sh`/binaries from Files search.

Optional **`omnicast-snippetd`** uses the `input` group (keystroke expansion). Only enable it if you understand that; it is not required for the launcher.

---

## License

[MIT](LICENSE)
