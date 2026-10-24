# Work order: Omarchy-first, then OPR

> Manhattan taken 2026-10-24. Default packaging path is **Omarchy plugin + OPR**, not AUR.

## Done
- [x] Manhattan non-AI loop + news
- [x] Catalog honesty, RootSearch modules, CI smoke
- [x] Hyprland float snaps + deeplinks + ADR 016/017
- [x] Bar widget uses plugin-local `bin/omnicast` (no PATH loophole)
- [x] `bin/omnicast-omarchy-setup` (CLI symlink + Alt+Space)
- [x] Docs: Omarchy integration checklist + OPR scaffold

## Now
1. [ ] Merge `koustav` → `main` (plugin-add clones default branch)
2. [ ] Dogfood: `omarchy plugin update` / re-add + setup on a clean Omarchy box
3. [ ] `omarchy plugin validate` on fresh clone from `main`
4. [x] OPR PR to `omacom/omarchy-pkgs` (`packaging/opr/`)

## Later
5. [ ] Index / handoff Omarchy plugin store in umbrella
6. [ ] Optional: generic Ollama/BYOK gateway
7. [ ] AUR only if targeting vanilla Arch (not Omarchy-default)

## Out of band
- Omarchy-LLM
