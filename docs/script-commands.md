# Omnicast Script Commands

Drop executable scripts into:

- `~/.config/omnicast/commands/` (user)
- `<repo>/src/commands/` (bundled)

## Frontmatter

```bash
#!/usr/bin/env bash
# @raycast.schemaVersion 1
# @raycast.title My Command
# @raycast.mode fullOutput
# @raycast.icon ⚡
# @raycast.packageName Utilities
# @raycast.description Short subtitle
# @raycast.argument1 { "type": "text", "placeholder": "Query", "name": "query" }
```

`@omarchy.*` keys are also accepted (same schema).

## Modes

| Mode | Behavior |
|---|---|
| `fullOutput` | Push result view with stdout as Markdown (default) |
| `silent` | Run in background, show HUD, no result view |
| `compact` | Same as silent for now (HUD with short status) |
| `inline` | Treated as compact until dedicated inline rows land |

## Arguments

Up to 3 `@raycast.argumentN` JSON objects. Omnicast opens a Form before running when arguments are declared.

## Examples

See `src/commands/system-info.sh` and `src/commands/ip-lookup.sh`.
