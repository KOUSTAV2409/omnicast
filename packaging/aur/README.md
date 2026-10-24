# AUR: `omnicast-git`

Draft package for the Arch User Repository. Submit only after you have an AUR account and SSH key.

## Contents

| File | Role |
|---|---|
| `PKGBUILD` | Builds from GitHub `master`/`main` tip |
| `.SRCINFO` | Regenerated before upload (`makepkg --printsrcinfo`) |

## Local test

```bash
cd packaging/aur
makepkg -si   # needs quickshell on the machine
omnicast --help
```

## Publish (maintainer)

```bash
# One-time: clone empty AUR package repo
git clone ssh://aur@aur.archlinux.org/omnicast-git.git
cd omnicast-git
cp /path/to/omnicast/packaging/aur/PKGBUILD .
makepkg --printsrcinfo > .SRCINFO
git add PKGBUILD .SRCINFO
git commit -m "omnicast-git: initial import"
git push
```

After the first push, bump with `pkgver()` from `git describe` and push PKGBUILD + `.SRCINFO` updates.

## Notes

- Runtime depends: `quickshell`, `python`, `wl-clipboard`, `xdg-utils`
- Soft depends: `fd`, `ripgrep`, `plocate` (file search)
- Omarchy CLI helpers are expected on Omarchy; package stays usable as a Quickshell config elsewhere with reduced handoffs
