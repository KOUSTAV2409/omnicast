# Omarchy integration checklist

Omnicast is an **Omarchy shell plugin** first. System packaging is **OPR** (`omacom/omarchy-pkgs` → `pkgs.omarchy.org`), not the AUR.

## Install contract (no loopholes)

| Step | Must work without extra knowledge |
|---|---|
| `omarchy plugin add <repo> --enable` | Passes `omarchy plugin validate` on a fresh git clone |
| Bar widget click | Runs **plugin-local** `bin/omnicast` (never assumes PATH) |
| `bin/omnicast-omarchy-setup` | Symlinks CLI + binds Alt+Space to that same binary |
| Super+Space | Remains Omarchy menu |
| Handoffs | Call `omarchy-menu-*` / `omarchy-menu summon …` after dismiss |
| Window snaps | Lua `hl.dsp.window.*` only (no classic `setfloating` batches) |

## Validate before every release

```bash
# Clean tree (no local video/node_modules symlinks)
omarchy plugin validate .

# Or stage like plugin-add:
git clone --depth=1 https://github.com/KOUSTAV2409/omnicast.git /tmp/omnicast-check
omarchy plugin validate /tmp/omnicast-check
```

`omarchy-plugin-validate` rejects **any symlink** under the plugin folder (except `.git`). Keep `node_modules/` gitignored.

## Branch note

`omarchy plugin add` clones the repo **default branch** (`main`). Ship Omarchy-facing fixes on `main` (merge `koustav` → `main`) or users stay on stale code.

## OPR vs plugin

| Surface | Role |
|---|---|
| Omarchy Plugins | Bar widget + git-managed launcher sources |
| OPR package | Optional `pacman -S omnicast` from `[omarchy]` for `/usr/bin/omnicast` |
| AUR | Not Omarchy-default (OPR stopped AUR sync). Keep only if targeting vanilla Arch |

## Known non-goals inside the plugin

- Do not ship `video/node_modules` or other symlink trees
- Do not require a global snippet daemon
- Do not reimplement Omarchy clipboard/emoji overlays
