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
- **File search**: type a name → Files section (`fd`, falls back to `plocate`) under `$HOME`  
  - Try: a folder/file name on your machine · Enter opens · Ctrl+K Copy Path / Reveal
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

## License

[MIT](LICENSE)
