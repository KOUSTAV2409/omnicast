# Omnicast

> First we take Manhattan, then we take Berlin.

**Alt+Space for Omarchy** — one launcher that searches your machine and either **hands off** to native Omarchy tools or **owns** the gaps they don’t cover.

Not a Raycast UI clone. An **Omarchy umbrella**: same muscle memory as a modern launcher, styled like Omarchy’s menu/clipboard surfaces, wired into Hyprland and the Omarchy CLI.

> Private while we dogfood. Not open for public install yet.

---

## Quick start (private testers · Omarchy only)

**Needs:** Omarchy (Hyprland) + Quickshell (`qs` on PATH). This will not run on macOS or a generic distro.

### 1. Get repo access
You’ll get a **GitHub collaborator invite** (to your GitHub account / email). Accept it, then:

```bash
# HTTPS (GitHub will prompt / use credential helper)
git clone https://github.com/KOUSTAV2409/omnicast.git
cd omnicast

# or SSH, if you use keys
# git clone git@github.com:KOUSTAV2409/omnicast.git
```

### 2. Run once
```bash
./bin/omnicast
```

You should see the launcher. Esc dismisses; run the same command again to toggle.

### 3. Bind Alt+Space
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

**Stuck?** Open an issue on the private repo or reply to the invite email / DM.

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
- Keybindings viewer  
- System menu, capture, share, reminders  

### Own (Omnicast fills the gap)
- **Apps & commands** — `.desktop` apps + Omarchy CLI catalog  
- **Calculator** — math, `#hex` colors, simple unit conversion  
- **Quicklinks** — bookmarks with `{argument}` / `{clipboard}` placeholders  
- **Script commands** — Raycast-style frontmatter (`@raycast.*` / `@omarchy.*`), form args, `silent` / `compact` / `fullOutput`  
- **Snippets** — manage + optional global expander (`bin/omnicast-snippetd`)  
- **Windows** — curated Omarchy Hyprland helpers (pop, gaps, transparency, layout) + Lua-safe float/fullscreen  
- **Fallbacks** — no match → Search Web or Ask AI  

### Not ready yet
- **AI** — UI exists; responses are still mocked (Ollama / BYOK next)  
- **File search** — prefer Omarchy file menu handoff for now  
- **Public packaging** — clone-and-run for Omarchy developers only  

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
| [`docs/script-commands.md`](docs/script-commands.md) | Script command API |
| [`docs/raycast-vs-omarchy.md`](docs/raycast-vs-omarchy.md) | Feature crosswalk |
| [`implementation-plan.md`](implementation-plan.md) | Manhattan → Berlin plan |
| [`roadmap.md`](roadmap.md) | Status snapshot |
| [`memory.md`](memory.md) | ADRs (incl. umbrella doctrine) |
| [`context.md`](context.md) | Agent / product context |

---

## Status

**Manhattan (umbrella):** ~90% — handoffs, search/ranking, calc, scripts, quicklinks, snippets, Windows palette, fallbacks.  

**Next:** real AI streaming (M4), then polish / optional file provider.

---

## License

Private / unlicensed while the project stays closed. Terms TBD before any public release.
