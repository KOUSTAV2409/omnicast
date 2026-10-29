# Omnicast deeplinks

Berlin surface: open Omnicast (or run a Hyprland snap) from scripts, Hyprland binds, and `xdg-open`.

## CLI

```bash
omnicast                         # toggle
omnicast show | dismiss | toggle
omnicast search foot
omnicast snap left               # no UI: snap active window
omnicast windows
omnicast snippets
omnicast plugins
omnicast ai
```

## URI scheme (`omnicast://`)

Registered by `install.sh` via `omnicast.desktop` (`MimeType=x-scheme-handler/omnicast`).

| URI | Effect |
|---|---|
| `omnicast://` / `omnicast://toggle` | Toggle launcher |
| `omnicast://show` | Show |
| `omnicast://dismiss` | Hide |
| `omnicast://search?q=foot` | Show root filtered to `foot` |
| `omnicast://foot` | Same as search for `foot` |
| `omnicast://snap?layout=left` | Snap active window (no UI) |
| `omnicast://windows` | Open Windows palette |
| `omnicast://snippets` | Open Snippets |
| `omnicast://plugins` | Open the Omarchy plugin directory |
| `omnicast://ai` | Open Ask AI |

### Snap presets

`left` · `right` · `top` · `bottom` · `left-third` · `center-third` · `right-third` · `top-left` · `top-right` · `bottom-left` · `bottom-right` · `center` · `maximize`

Example Hyprland bind (Lua):

```lua
o.bind("SUPER + ALT + LEFT", "Snap left", "omnicast snap left")
o.bind("SUPER + ALT + RIGHT", "Snap right", "omnicast snap right")
```

## Security

- Snap and IPC only act as your user on the local session.
- Search queries are not passed to a shell; they set the in-app filter text.
- Unknown URI hosts/paths fall through to search text (no remote fetch).
