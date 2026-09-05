# Work order — take Manhattan (non-AI)

> Ordered setup for the next Omnicast stretch. AI and Omarchy-LLM stay out of band (ADR 015).

## 0. Communications (do first)
1. [ ] Post Twitter/X update (draft below / in chat)
2. [ ] Point people at https://omnicast.best and https://omnicast.best/news/
3. [ ] Keep disclaimer visible: not affiliated with omarchy.org; intends to be

## 1. Dogfood pass (find truth)
Run Alt+Space through the daily loop on a clean Omarchy box. Note every break.

Loop checklist:
- [ ] Launch apps (fuzzy + frecency)
- [ ] Handoff: clipboard, emoji, theme, background, images, keybindings, menu, Find Files
- [ ] Own: calc, quicklinks, scripts (+ form args), snippets (+ snippetd optional)
- [ ] Windows: pop / gaps / float / curated helpers
- [ ] No-match → Search Web (Ask AI stub OK)
- [ ] HUD, Esc dismiss, Ctrl+K actions

Output: a short gap list (file issues or checklist in this doc).

## 2. Close non-AI gaps (priority order)
Fix only what the dogfood pass proves broken or missing.

1. **Root / catalog honesty** — empty states; no false fallbacks while catalogs scan  
2. **Script commands** — arg forms, failure HUD, docs accuracy  
3. **Windows / Hyprland helpers** — broken or missing daily actions  
4. **Quicklinks / snippets / calc** — edge cases from real use  
5. **Install docs** — README + site stay accurate for newcomers  

## 3. Declare Manhattan
When the loop in §1 is trustworthy:
- [ ] Check off M5 in `implementation-plan.md` / `roadmap.md`
- [ ] News post: “Manhattan taken (non-AI)”
- [ ] Optional short tweet

## 4. Berlin (only after §3)
1. Packaging (AUR / omarchy plugin path)  
2. Deeplinks  
3. One Hyprland-only killer workflow  
4. Index / handoff Omarchy plugin store  
5. Extension strategy ADR  
6. Optional later: generic Ollama/BYOK gateway (still not Omarchy-LLM)

## Out of band (never in this queue)
- Real AI streaming for Manhattan  
- Omarchy-LLM training / research  

---

## Tweet draft (single post)

```
Omnicast is public.

https://omnicast.best
https://github.com/KOUSTAV2409/omnicast

Alt+Space umbrella for Omarchy — handoff native tools, own the gaps.

Not affiliated with @OmarchyLinux / omarchy.org. Independent community project that intends to be.

Manhattan = finish every non-AI tool first. AI later. Custom Omarchy LLM stays a separate mission.

Clone, bind Alt+Space, tell me what breaks.
First we take Manhattan, then we take Berlin.
```
