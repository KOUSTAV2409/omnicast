# Work order: Berlin (post-Manhattan)

> Manhattan (non-AI) declared taken 2026-10-24. AI and Omarchy-LLM stay out of band (ADR 015).

## Done (Manhattan)
- [x] Non-AI dogfood: backends smoke + Omarchy handoff/window binaries present
- [x] Catalog honesty: no Web/AI fallbacks while catalogs/files load
- [x] Doc sync: remove snippetd promises; honest Ask AI = mock
- [x] News: Manhattan taken
- [x] RootSearch split: `src/views/root/{Calc,PathSafety,Handoffs,WindowActions}.js`
- [x] CI smoke + AUR PKGBUILD draft

## Berlin next
1. [ ] Submit AUR `omnicast-git` (PKGBUILD + README ready in `packaging/aur/`)
2. [x] Deeplinks `omnicast://…` (`docs/deeplinks.md`)
3. [x] Hyprland float snaps (`window_snap.py` + Windows palette)
4. [x] Extension strategy ADR 016
5. [ ] Optional: generic Ollama/BYOK gateway (still not Omarchy-LLM)
6. [ ] Index / handoff Omarchy plugin store in umbrella

## Out of band
- Real AI streaming for Manhattan (already closed without it)
- Omarchy-LLM training / research
