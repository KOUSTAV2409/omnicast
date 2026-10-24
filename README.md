# Omnicast

> First we take Manhattan, then we take Berlin.

**Alt+Space for Omarchy**: one launcher that searches your machine and either **hands off** to native Omarchy tools or **owns** the gaps they don’t cover.

Not a Raycast UI clone. An **Omarchy umbrella**: same muscle memory as a modern launcher, styled like Omarchy’s menu/clipboard surfaces, wired into Hyprland and the Omarchy CLI.

**Site:** [omnicast.best](https://omnicast.best) · **News:** [omnicast.best/news](https://omnicast.best/news/) · **Code:** [github.com/KOUSTAV2409/omnicast](https://github.com/KOUSTAV2409/omnicast) · **X:** [@koustavdotco](https://x.com/koustavdotco)

> **Not affiliated with [omarchy.org](https://omarchy.org).** Independent community project that intends to earn a place in that ecosystem.

### Tell your agent

Paste this to Cursor / Claude / ChatGPT on an Omarchy machine:

```text
Set up Omnicast on this Omarchy box:
1. omarchy plugin add https://github.com/KOUSTAV2409/omnicast.git --enable
2. ~/.config/omarchy/plugins/koustav.omnicast/bin/omnicast-omarchy-setup
3. Confirm Alt+Space toggles Omnicast; Super+Space stays the Omarchy menu
```

---

## Quick start (Omarchy only)

**Needs:** Omarchy (Hyprland + Quickshell). Omnicast is an **Omarchy shell plugin**, not an AUR app.

### Recommended: Omarchy Plugins (marketplace path)

```bash
omarchy plugin add https://github.com/KOUSTAV2409/omnicast.git --enable
~/.config/omarchy/plugins/koustav.omnicast/bin/omnicast-omarchy-setup
```

What that does:
1. Installs the plugin under `~/.config/omarchy/plugins/koustav.omnicast/`
2. Enables the bar widget (search icon). The widget always calls the **plugin-local** `bin/omnicast` (no PATH dependency)
3. `omnicast-omarchy-setup` symlinks CLI to `~/.local/bin/omnicast` and binds **Alt+Space** (leaves **Super+Space** for the Omarchy menu)

Update later: `omarchy plugin update koustav.omnicast` then re-run setup if the bind path changed.

Listing: [Omarchy Plugins · koustav.omnicast](https://omarchyplugins.com/plugin.html?id=koustav.omnicast)

### Optional later: OPR system package

Omarchy’s package repo is **OPR** (`pkgs.omarchy.org` via [`omacom/omarchy-pkgs`](https://github.com/omacom/omarchy-pkgs)), not the AUR. Scaffold: [`packaging/opr/`](packaging/opr/). Submit after the plugin path is airtight.

### Standalone clone (developers)

```bash
git clone --depth=1 https://github.com/KOUSTAV2409/omnicast.git ~/.local/share/omnicast
bash ~/.local/share/omnicast/install.sh
```

Or from a working tree: `./bin/omnicast` and `./bin/omnicast-omarchy-setup`.

Script commands: drop executables in `~/.config/omnicast/commands/`. See [`docs/script-commands.md`](docs/script-commands.md).

Snippets are managed inside the launcher (no global keystroke expander).

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
- **Snippets**: manage and insert text snippets from the launcher (no global expander daemon)
  - Try: open **Snippets** → Enter to insert into active window, or Ctrl+C to copy
- **Windows**: Hyprland **float snaps** (left/right/thirds/quarters) + Omarchy helpers (pop, gaps, transparency, layout)  
  - Try: `snap left`, open **Windows**, or `omnicast snap left` / `omnicast://snap?layout=left`
- **Fallbacks**: no match → Search Web or Ask AI  
  - Try: type nonsense → **Search Web** / **Ask AI** rows appear

### Not ready yet
- **AI**: UI stub only; **deferred** (post-Manhattan). Custom Omarchy-LLM is a separate mission outside this repo.  
- **OPR package**: scaffold under `packaging/opr/` (Omarchy pkg repo). AUR is not the Omarchy default path.

Full Raycast ↔ Omarchy map: [`docs/raycast-vs-omarchy.md`](docs/raycast-vs-omarchy.md) · Omarchy integration: [`docs/omarchy-integration.md`](docs/omarchy-integration.md)

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
| [`src/views/root/`](src/views/root/) | Calc / PathSafety / Handoffs / WindowActions modules |
| [`tests/smoke_backends.sh`](tests/smoke_backends.sh) | Backend + packaging smoke |
| [`packaging/opr/`](packaging/opr/) | OPR (`omarchy-pkgs`) recipe scaffold |
| [`bin/omnicast-omarchy-setup`](bin/omnicast-omarchy-setup) | Post-plugin PATH + Alt+Space bind |
| [`docs/work-order.md`](docs/work-order.md) | Ordered next actions (Berlin) |
| [`site/`](site/) | Public landing + news |
| [`docs/script-commands.md`](docs/script-commands.md) | Script command API |
| [`docs/raycast-vs-omarchy.md`](docs/raycast-vs-omarchy.md) | Feature crosswalk |
| [`implementation-plan.md`](implementation-plan.md) | Manhattan → Berlin plan |
| [`roadmap.md`](roadmap.md) | Status snapshot |
| [`memory.md`](memory.md) | ADRs (incl. umbrella doctrine) |
| [`context.md`](context.md) | Agent / product context |

---

## Status

**Manhattan (non-AI umbrella): taken.** Daily loop works without real AI. Ask AI stays mocked.

**Berlin:** Omarchy-first hardening, then OPR. Float snaps + deeplinks shipped. Omarchy-LLM stays out of band. Deeplinks: [`docs/deeplinks.md`](docs/deeplinks.md). Public site: [omnicast.best](https://omnicast.best).

Full leftover backlog: [`roadmap.md`](roadmap.md) → **What’s left to build**.

---

## Security (local desktop)

Omnicast is a **local** Alt+Space launcher. Cloning it from GitHub does **not** give anyone remote access to your machine. It runs as your user, like a browser or editor.

Hardening includes: secrets/session paths blocked from search & preview, owner-only cache (`0600`), no shell launch of desktop `Exec=` lines, script commands only from allowlisted folders, and no executing `.sh`/binaries from Files search.

---

## License

[MIT](LICENSE)
