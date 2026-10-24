# OPR package scaffold (`omnicast`)

Omarchy’s official package channel is **OPR**, not the AUR:

- Recipes: [`omacom/omarchy-pkgs`](https://github.com/omacom/omarchy-pkgs)
- Built packages: `https://pkgs.omarchy.org/{edge,rc,stable}/$arch`
- Pacman repo on Omarchy: `[omarchy]`

Submit only **after** the Omarchy plugin path is airtight (`docs/omarchy-integration.md`).

## What this package should install

| Path | Content |
|---|---|
| `/usr/share/omnicast/` | `src/`, `bin/`, `manifest.json`, `BarWidget.qml`, `LICENSE`, `README.md` |
| `/usr/bin/omnicast` | symlink → `/usr/share/omnicast/bin/omnicast` |
| `/usr/share/applications/omnicast.desktop` | `Exec=omnicast %u` + `MimeType=x-scheme-handler/omnicast` |
| `/usr/share/licenses/omnicast/LICENSE` | MIT |

Users still enable the **bar widget** via:

```bash
omarchy plugin add https://github.com/KOUSTAV2409/omnicast.git --enable
```

(or a future OPR post-install note). The plugin and the OPR package can coexist: plugin for shell integration, package for `/usr/bin` + desktop MIME.

## Submit flow

1. Fork `omacom/omarchy-pkgs`, branch from `master`
2. `bin/add-package omnicast --local --scaffold`
3. Copy/adapt `packaging/opr/PKGBUILD` into `pkgbuilds/omnicast/PKGBUILD`
4. Add `pkgbuilds/omnicast/.omarchy/package.json` (see example below)
5. **Pin** the git source with `#commit=<sha>` (unpinned sources are rejected)
6. `updpkgsums` · `bin/build --package omnicast`
7. Open a one-package PR

### `.omarchy/package.json` example

```json
{
  "source": "local",
  "upstream": {
    "watch": {
      "git_tags": "https://github.com/KOUSTAV2409/omnicast.git",
      "pattern": "(?P<version>[0-9]+(?:\\.[0-9]+)*)"
    }
  }
}
```

Until tags exist, set `"sync": false` and bump `pkgver`/`commit` by hand.

## Do not

- Do not submit to the AUR as the Omarchy primary path
- Do not leave git sources unpinned
- Do not ship `video/` or `node_modules` inside the package
