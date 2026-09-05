# Omnicast

> First we take Manhattan, then we take Berlin.

**Alt+Space for Omarchy** — one launcher that searches your machine and either **hands off** to native Omarchy tools or **owns** the gaps they don’t cover.

Not a Raycast UI clone. An **Omarchy umbrella**: same muscle memory as a modern launcher, styled like Omarchy’s menu/clipboard surfaces, wired into Hyprland and the Omarchy CLI.

**Site:** [omnicast on GitHub Pages](https://koustav2409.github.io/omnicast/) · **Repo:** public — clone and run.

### Tell your agent

Paste this to Cursor / Claude / ChatGPT on an Omarchy machine:

```text
Set up Omnicast on this Omarchy box:
1. Clone https://github.com/KOUSTAV2409/omnicast.git
2. Run ./bin/omnicast once to verify the launcher.
3. Bind Alt+Space in ~/.config/hypr/bindings.lua to the absolute path of bin/omnicast.
   Keep Super+Space for the Omarchy menu.
4. Do not change Hyprland gaps/rounding globally. Follow README Quick start only.
```

---

## Quick start (Omarchy only)

**Needs:** Omarchy (Hyprland) + Quickshell (`qs` on PATH). This will not run on macOS or a generic distro.

```bash
git clone https://github.com/KOUSTAV2409/omnicast.git
cd omnicast
./bin/omnicast
```

You should see the launcher. Esc dismisses; run the same command again to toggle.

### Bind Alt+Space

In `~/.config/hypr/bindings.lua` (or your Omarchy bindings file):

```lua
o.bind("ALT + SPACE", "Omnicast", "/home/YOURUSER/omnicast/bin/omnicast")
```

Use the **absolute path** to your clone. Keep **Super+Space** for the Omarchy menu.

### Optional

```bash
# Global snippet expander (python-evdev + membership in `input` group)
./bin/omnicast-snippetd
```

Script commands: drop executables in `~/.config/omnicast/commands/` — see [`docs/script-commands.md`](docs/script-commands.md).

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
- **Apps & commands** — `.desktop` apps + Omarchy CLI catalog  
  - Try: `foot`, `screenshot`, `nightlight` (→ Omarchy: Toggle Nightlight)
- **Calculator** — math, `#hex` colors, units, rough FX (verify on Google), dates  
  - Try: `12*7+3` · `#ff8800` · `10 km to mi` · `10 usd to inr` (shows ≈ guess + Google live rate) · `days until 2026-12-25`
- **Quicklinks** — bookmarks with `{argument}` / `{clipboard}` placeholders  
  - Try: open **Quicklinks**, or search a link title you saved
- **Script commands** — Raycast-style frontmatter (`@raycast.*` / `@omarchy.*`), form args, `silent` / `compact` / `fullOutput`  
  - Drop scripts in `~/.config/omnicast/commands/` — see [`docs/script-commands.md`](docs/script-commands.md)
- **Snippets** — manage + optional global expander (`bin/omnicast-snippetd`)  
  - Try: open **Snippets**, or type a keyword like `:shrug` if snippetd is running  
  - Settings: `~/.config/omnicast/snippetd.json` → `{ "delay_ms": 150, "backend": "auto" }` (`wtype` / `ydotool`)
- **Windows** — curated Omarchy Hyprland helpers (pop, gaps, transparency, layout) + Lua-safe float/fullscreen  
  - Try: `pop`, `gaps`, `float` — or open **Windows**
- **Fallbacks** — no match → Search Web or Ask AI  
  - Try: type nonsense → **Search Web** / **Ask AI** rows appear

### Not ready yet
- **AI** — UI exists; responses are still mocked (Ollama / BYOK next)  
- **Packaged install** — clone-and-run for now (AUR / plugin path later)

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
| [`site/`](site/) | Public landing page |
| [`docs/script-commands.md`](docs/script-commands.md) | Script command API |
| [`docs/raycast-vs-omarchy.md`](docs/raycast-vs-omarchy.md) | Feature crosswalk |
| [`implementation-plan.md`](implementation-plan.md) | Manhattan → Berlin plan |
| [`roadmap.md`](roadmap.md) | Status snapshot |
| [`memory.md`](memory.md) | ADRs (incl. umbrella doctrine) |
| [`context.md`](context.md) | Agent / product context |

---

## Status

**Manhattan (umbrella):** ~90% — handoffs, search/ranking, calc, scripts, quicklinks, snippets, Windows palette, fallbacks.  

**Next:** real AI streaming (M4). Public clone-and-run is open; packaging still later.

Full leftover backlog: [`roadmap.md`](roadmap.md) → **What’s left to build**.

---

## License

[MIT](LICENSE)
