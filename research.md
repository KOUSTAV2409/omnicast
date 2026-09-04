# Omnicast Product Research: Raycast End-to-End

> **Document type:** Independent competitive / product research  
> **Audience:** Omnicast builders (Manhattan = parity → Berlin = beat Raycast)  
> **Research date:** 2026-09-04  
> **Method:** Parallel research streams against primary sources (raycast.com, Manual, Developers API, changelogs), clone/alternative GitHub & docs, design/review commentary, and YouTube UX reviews.

---

## Executive summary

**Raycast** is a keyboard-first, extensible productivity launcher that absorbed five separate Mac utilities (launcher, clipboard, snippets, window manager, emoji) into one palette — then layered a Store (React/TS extensions), Script Commands, and an AI-native OS surface (Quick AI, Chat, Agents, Dictation, MCP). In 2026 it shipped **Raycast 2.0** (cross-platform rewrite: macOS + Windows + iOS), Liquid Glass UI, inline File Search, Screen Awareness, Memory/Profile/Agents/Skills, and BYO/local models (Pro).

**Why it feels “polished, genuine, intuitive”:** one interaction grammar (`↵` / `⌘K` / `Esc`), enforced UI primitives (List / Grid / Detail / Form / Action Panel), footer discoverability, frecency ranking, paint-UI-first latency, HUD/toast feedback, and extensions that cannot invent random UIs.

**Linux copy landscape:** Most attempts stay Rofi-class (fast, scriptable, unproductized). The standout is **Vicinae** (~9.3k★) — native C++/Qt with partial Raycast extension compatibility. **Walker + Elephant** is the best modular “good enough for 1–2 workflows” stack on Hyprland/Omarchy. Tauri clones (Flare, Beam, Asyar) prove demand but stumble on dogfooding, Wayland, or ecosystem depth.

**Omnicast wedge:** Wayland/Hyprland-native (layer-shell), Omarchy-first OS fusion, local-first AI, and Raycast-grade Action Panel UX — without needing Raycast’s cloud subscription to unlock themes/WM/clipboard depth.

---

## How to read this document

| Section | Contents |
|---|---|
| **Executive summary** (above) | Verdict in one screen |
| **Main body** (next) | Full Raycast product inventory — features, AI, Store, Script Commands, shortcuts, pricing, 2024–2026 direction |
| **[APPENDIX A](#appendix-a--uiux-research-full)** | UI/UX deep dive — layout zones, visual language, micro-interactions, Action Panel, parity principles |
| **[APPENDIX B](#appendix-b--clones--alternatives-full)** | Every notable clone/alternative — comparison table + deep dives (Vicinae, Walker, Flare, Sol, Asyar, …) |
| **[§8 Manhattan checklist](#8-manhattan-parity-checklist-for-omnicast)** | Raycast → Omnicast gap map |
| **[§9 Berlin](#9-berlin-how-to-beat-raycast-on-omarchy)** | Where Omarchy can win |
| **[§10 Sources](#10-sources-master-index)** | Master URL index |

---

# MAIN BODY — Raycast Product Inventory

*Primary sources: raycast.com, manual.raycast.com, developers.raycast.com, pricing, changelog (researched 2026-09-04).*

---


**Research date:** 2026-09-04  
**Primary sources:** [raycast.com](https://www.raycast.com), [manual.raycast.com](https://manual.raycast.com), [developers.raycast.com](https://developers.raycast.com), pricing, changelog, blog

---

## 1. Official product overview

**Raycast** is an extensible, keyboard-first productivity launcher and OS-level toolbox. Positioning (homepage): *“Your shortcut to everything”* — apps, files, extensions, AI, and dictation one keystroke away.

| Attribute | Detail |
|---|---|
| Platforms | **macOS** (Apple silicon; v2 requires Tahoe per manual), **Windows** (10+, x64/ARM), **iOS/iPadOS** |
| Origin | Launched ~2020 as macOS-native; **Raycast 2.0** (public beta May 2026, GA ~Aug 25 2026) is a cross-platform rewrite |
| Architecture (v2) | Native host (Swift/AppKit macOS; C#/.NET 8 + WPF Windows) + shared **React/TS WebView UI** + long-lived **Node** backend + **Rust** core (file indexer, sync schema, shared data layer) |
| Monetization | Generous free core; **Pro** unlocks AI, sync, unlimited notes/clipboard, custom WM/themes, translator; Teams/Enterprise for orgs |
| Reliability claim | **99.8% crash-free** (homepage) |
| Community | Slack ~37k, X/Twitter ~90k (homepage) |

**Sources:** https://www.raycast.com · https://manual.raycast.com · https://www.raycast.com/blog/a-technical-deep-dive-into-the-new-raycast · https://www.raycast.com/changelog

---

## 2. Complete feature inventory

### 2.1 Core launcher / search

| Capability | Notes |
|---|---|
| **Root Search** | Single search bar + results list; entry point for everything |
| **App launch** | Fuzzy match (`msg` → Messages, `slk` → Slack); Favorites pinning |
| **Commands** | Built-in + extension + script + AI commands |
| **Files & folders** | Inline in Root Search when File Search indexing is on; recent files when empty |
| **Calendar events** | Upcoming today at top of empty Root Search (permissions) |
| **Quicklinks** | URLs, files, folders, apps as searchable shortcuts |
| **Calculator** | Inline expression evaluation in Root Search |
| **Color conversion** | Paste `#FF6B35`, `rgb()`, `hsl()`, `oklch()` → preview + copy formats |
| **URL detection** | Typed URLs / domains → open/browser actions; infers `https://` |
| **Contacts** | macOS: Search Contacts (Apple Contacts) |
| **Windows Settings** | Windows: full Settings/Control Panel catalog searchable |
| **Compact Mode** | Window collapses to search bar when empty |
| **Ranking** | Exact alias → alias prefix → fuzzy title → subtitle/keywords → **frecency**; Reset Ranking per item |
| **Search sensitivity** | High / Medium / Low fuzzy strictness |
| **Fallback commands** | e.g. Quick AI, Ask File Search when no matches |
| **Command arguments** | Up to 3 args (text / password / dropdown) in search bar |
| **File nav in search** | `Shift Tab` → parent directory |

**Sources:** https://manual.raycast.com/search-bar.md · https://manual.raycast.com/quickstart.md · https://manual.raycast.com/file-search.md

---

### 2.2 Navigation & UI primitives

#### End-user navigation

| Feature | Detail |
|---|---|
| **Action Panel** | `⌘K` / `Ctrl K` — every contextual action for selection |
| **Switch Windows** | Search open windows by app/title; minimize/close/fullscreen/hide via Action Panel |
| **Menu Bar Actions** | Trigger any app’s menu bar items from keyboard (Navigation feature) |
| **Pop to Root** | `⌘ Esc` (Mac) / `⇧ Esc` (Windows) |

#### Extension API UI (developer “design system”)

| Component | Role |
|---|---|
| **List** | Default UI; sections, accessories, detail pane, built-in/custom filtering, loading |
| **Grid** | Image-first items; columns, inset sizes |
| **Detail** | Markdown/HTML-rich detail views |
| **Form** | Data collection: TextField, PasswordField, TextArea, Checkbox, DatePicker, Dropdown, TagPicker, FilePicker, Separator, Description, LinkAccessory |
| **Action Panel + Actions** | Primary/secondary/tertiary shortcuts; open, copy, paste, push, submit, etc. |
| **Navigation** | Stack push/pop between views |
| **MenuBarExtra** | macOS menu bar extras (not on Windows); background refresh intervals |
| **Feedback** | Toast, HUD, Alert |
| **Window & Search Bar** | Navigation title, placeholders, accessories |

Command modes include view UI, no-view scripts, and menu-bar.

**Sources:** https://developers.raycast.com/api-reference/user-interface.md · List/Grid/Form/Action Panel docs · https://manual.raycast.com/action-panel.md · https://manual.raycast.com/navigation.md

---

### 2.3 Built-in extensions / power tools

#### Clipboard History
- Searchable history: text, images, files, links, emails, colors  
- Filter by type (`⌘P` / `Ctrl P`)  
- Paste / Copy; prefer plain text; paste sequences; rename entries; QR text from images; grouped multi-copy  
- Free: **3 months** retention · Pro: **Unlimited**  
**Source:** https://manual.raycast.com/clipboard-history.md · pricing

#### Snippets
- Keyword auto-expansion in any app  
- Search/Create/Import/Export; tags, pin; placeholders  
- Import from TextExpander, aText, Espanso, PhraseExpress, JSON  
- Response-time tuning for expansion reliability  
**Source:** https://manual.raycast.com/snippets.md

#### Quicklinks
- Open URLs / files / folders / apps; dynamic placeholders; searchable  
**Source:** https://manual.raycast.com/quicklinks.md

#### Window Management
- Halves, thirds, fourths, sixths, quarters, maximize, center, restore, reasonable size  
- Move/Resize to exact pixels (`1920x1080`, `100,100`)  
- Multi-display; Spaces (Mac); virtual desktops (Windows Open/Close/Rename/Move Desktop 1–9)  
- **Custom layouts** (Pro): Create Layout / Create Layout From Current Windows; launch apps with CLI args  
- Gaps, half-cycling, Stage Manager respect, preset hotkeys from other WM apps  
**Source:** https://manual.raycast.com/window-management.md · changelog v2.2

#### File Search
- Own **Rust indexer** (v2; not Spotlight-only)  
- Root Search + dedicated Search Files (metadata/details)  
- Content search (OS-index dependent); ignore patterns; scopes; hidden files  
- AI Extensions: `@file-search`, `@finder`  
**Source:** https://manual.raycast.com/file-search.md · technical deep dive

#### Calculator
- Math, units, currencies (+ crypto), timezones, dates, work hours/days, pixels/PPI, trig, discounts/tips, airports/cities  
- Inline in Root Search; copy answer / unformatted / Q+A  
**Source:** https://manual.raycast.com/calculator.md

#### Emoji & Symbols
- Search by name/keyword; AI results; paste anywhere; grid sizes; **inline emoji picker** (v2.1)  
**Source:** https://manual.raycast.com/emoji-symbols.md · manual home

#### Calendar (“My Schedule”)
- EventKit / macOS Calendar accounts (Google, iCloud, Exchange, etc.)  
- Join calls, RSVP, block time, email attendees, copy availability  
- Create Event; menu bar next-meeting; AI `@calendar`  
**Source:** https://manual.raycast.com/calendar.md

#### Notes
- Lightweight Markdown notes; stack UI; Search/Create/Toggle window  
- Free: **5 notes** · Pro: **Unlimited**; sync across Mac/Windows/iOS  
**Source:** https://manual.raycast.com/notes.md · pricing

#### Focus
- Distraction blocking (apps/websites); categories; pause/resume/edit  
- Natural-language durations; deeplinks `raycast://focus/start|toggle|complete`  
- AI `@raycast-focus`  
**Source:** https://manual.raycast.com/focus.md

#### Screenshots
- Search/browse/preview/copy screenshots; grid column density  
**Source:** https://manual.raycast.com/screenshots.md

#### Translate (Pro)
- Live translate; detect language; swap; paste to active app; continue in AI Chat  
- Inline: `hello in german` / `"good night" into french`  
- Custom fixed language-pair commands  
**Source:** https://manual.raycast.com/translate.md

#### System Commands
Power/session (lock, sleep, hibernate, restart, shutdown, logout, screensaver), audio/media, display/appearance (dark mode, Stage Manager, HDR, Night Light), trash, eject disks, quit-all variants, dismiss notifications, Bluetooth, etc.  
**Source:** https://manual.raycast.com/system-commands.md

#### Hyper Key
- Remap Caps Lock / modifier / F-key → Hyper (`✦`); Quick Press behaviors; diagnostic  
**Source:** https://manual.raycast.com/hyper-key.md

#### Dynamic Placeholders
`{clipboard}`, `{cursor}`, `{date}`, `{time}`, `{datetime}`, `{day}`, `{uuid}`, `{selection}`, `{argument}`, `{calculator}`, `{snippet}`, `{browser-tab}` + modifiers (`uppercase`, `trim`, `percent-encode`, …) and date offsets/formats  
**Source:** https://manual.raycast.com/dynamic-placeholders.md

#### Themes (Pro)
- Theme Studio; light/dark; share via themes.ray.so URLs/JSON  
**Source:** https://manual.raycast.com/themes.md

#### Cloud Sync (Pro)
Sync categories: AI Commands & Agents, Chat History, MCP Servers, Quicklinks, Notes, Snippets, Themes, Transcription Styles, WM Layouts, Extensions (enable per device), plus selected general settings  
**Source:** https://manual.raycast.com/cloud-sync.md

#### Auto Quit
- Quit apps after inactivity (1–15 min); skips recording/media/frontmost  
**Source:** https://manual.raycast.com/auto-quit.md

#### Run (Windows)
- Replace Windows Run dialog: apps, Control Panel, MMC, paths, shell URIs  
**Source:** https://manual.raycast.com/run.md

#### Games (Windows)
- Discover Steam/Epic/GOG/etc.; Game Mode silences hotkeys  
**Source:** https://manual.raycast.com/games.md

#### Other homepage-mentioned tools
Flight Tracker (called out as **coming soon** / not yet in v2 on new-in-v2), Search Screenshots, Apple Reminders (via extensions/system), browser extension companion.

---

### 2.4 AI features (Pro exclusive; Advanced AI add-on for frontier models)

| Feature | What it does |
|---|---|
| **Quick AI** | One-off Q&A from Root Search (`Tab`); follow-ups; paste formatted; fallback command |
| **AI Chat** | Dedicated chat window: history, folders, pin/archive, branching, attachments, model switch mid-chat, creativity/reasoning, background notifications, long-context summarization |
| **Dictation** | System-wide speech→text; auto styling; custom vocab/instructions/styles; history; push-to-talk / toggle; Dictate in AI Chat |
| **Screen Awareness** | Focused window content + selection + screenshot → AI (`@screen-awareness`) |
| **AI Commands** | Saved prompts as commands; selection placeholders; Quick Fix (spelling/grammar); Open in Raycast vs Replace Selection |
| **AI Extensions** | Natural-language tools into extensions (`@calendar`, `@file-search`, etc.) |
| **Agents** | Saved setups (name, instructions, model, tools); formerly “Presets” |
| **Skills** | Reusable knowledge/instructions auto-applied when relevant |
| **MCP** | Connect Model Context Protocol servers as tools |
| **Personalization** | Editable **Profile** + automatic **Memory** |
| **BYOK** | Own Anthropic / Google / OpenAI / OpenRouter keys (usage billed to provider; Raycast rate limits skip) |
| **Custom Providers** | Any OpenAI-compatible endpoint (Pro; restored in v2.2) |
| **Local Models** | Ollama on-device (Pro; restored in v2.2) |
| **Models UI** | Manage/compare models: https://www.raycast.com/core-features/ai/models |

**Usage limits (official):**
- Free trial-ish: **50 free messages** (Mac v1 / iOS docs still list this)  
- Pro: unlimited to Pro models; **50/min**, **300/hour**; some mini models **150/24h**  
- Advanced AI: higher caps + frontier; e.g. **75/3h**, **150/24h**; some Opus/o1/GPT-* **50/week/model**  

**Sources:** https://manual.raycast.com/ai.md · subpages under `/ai/` · https://manual.raycast.com/ai/usage-limits.md · pricing

---

### 2.5 Extensions Store & developer platform

| Aspect | Detail |
|---|---|
| **Store** | Community + first-party extensions; browse by All / Recent / Popular; web + in-app |
| **Scale** | Homepage: “thousands”; popular extensions hundreds of thousands of installs (e.g. Kill Process ~692k) |
| **Stack** | TypeScript, React, Node; npm; strongly typed `@raycast/api`; hot reload; CLI lint/build |
| **AI Extensions** | Tools, evals, best practices for LLM-callable extension tools |
| **Teams private store** | Org-private extensions |
| **Capabilities** | OAuth, preferences, local storage/cache, clipboard, AI hooks, browser extension API, background refresh, menu bar, window management API, deeplinks, utilities (`useFetch`, `useForm`, `useAI`, …) |
| **Cross-platform** | Build once for macOS + Windows (platform-gated commands possible) |
| **Review** | Store review + extension guidelines |

**Sources:** https://www.raycast.com/store · https://developers.raycast.com · https://manual.raycast.com/extensions.md · https://developers.raycast.com/llms.txt

**Representative popular extensions:** Linear, Slack, Spotify, Chrome, VS Code, 1Password, Notion, Jira, Zoom, Brew, Color Picker, Google Translate, Arc, Obsidian, Todoist, CleanShot X, TinyPNG, Kill Process, Can I Use, Mole, Kaomoji, GIPHY, etc.

---

### 2.6 Script Commands

- Lightweight alternative to full extensions  
- Metadata header (`@raycast.title`, `.mode`, `.icon`, args, refresh…)  
- Languages: Bash/zsh, Python, Node, Ruby, PHP, Swift, AppleScript (Mac); PowerShell, C#, Python, Node, Bash (Windows)  
- Modes: silent, compact, full output, etc. (repo documents full set)  
- Create Script Command + Add Script Directory; hotkeys/aliases  
- Community repo: https://github.com/raycast/script-commands  

**Source:** https://manual.raycast.com/script-commands.md

---

### 2.7 Hotkeys, aliases, deeplinks

| Mechanism | Behavior |
|---|---|
| **Global Raycast hotkey** | Default `⌘ Space` / `Alt Space` (customizable) |
| **Command hotkeys** | Any command/app/quicklink — Action Panel → Configure → Set Hotkey |
| **Aliases** | Short keywords that jump a command to the top |
| **Hyper Key** | Extra modifier layer for conflict-free shortcuts |
| **Deeplinks** | `raycast://extensions/<author>/<extension>/<command>?arguments=&context=&fallbackText=&launchType=` |
| **Built-in deeplink examples** | Focus: `raycast://focus/start?goal=…&categories=…&duration=…&mode=block` |
| **Copy Deeplink** | Action on commands; confirmation dialog on launch |
| **createDeeplink** utility | For extensions |

**Sources:** https://manual.raycast.com/command-aliases-and-hotkeys.md · https://developers.raycast.com/information/lifecycle/deeplinks.md · Focus manual

---

### 2.8 Teams / Pro / pricing tiers

Prices from https://www.raycast.com/pricing (as of research):

| Plan | Price | Unlocks |
|---|---|---|
| **Free** | $0 | Core: Clipboard (3 mo), Quicklinks, Calculator, Snippets, WM (+ more), Hyper Key, Store, custom extensions, developer tooling; Notes **5**; Teams Free sharing caps |
| **Pro** | **$10/mo** or **$8/mo annual (−20%)** | All Free + **AI suite**, Cloud Sync, Dictation, Translator, Unlimited Notes, Unlimited Clipboard, Custom WM commands, Custom Themes |
| **Advanced AI add-on** | **+$8/mo** (or +$8/user/mo on Teams) | Frontier models + higher request limits |
| **Teams Free** | $0/user | Free features + Shared Commands **≤5**, Shared Quicklinks **≤30**, Shared Snippets **≤30** |
| **Teams Pro** | **$15/user/mo** or **$12/user/mo annual** | Pro for all + unlimited shared commands/quicklinks/snippets |
| **Enterprise** | Custom | Teams Pro + AI Control Center (org AI toggle, BYOK, provider allow-list, custom provider) + Admin (SAML/SCIM, domain capture, cloud sync control, 2FA enforcement, extensions allow-list, IP allow-list) |

**Billing notes:** Account-based across Mac/Windows/iOS; **7-day Pro trial** (once per account); yearly −20%. Student program mentioned as FAQ on pricing page.

**Sources:** https://www.raycast.com/pricing · https://manual.raycast.com/billing.md · https://manual.raycast.com/teams.md · https://manual.raycast.com/enterprise.md

---

### 2.9 Integrations

| Type | Examples |
|---|---|
| **First-party OS** | Calendar (EventKit), Contacts, Screenshots, System, Window Mgmt, File index |
| **Companion** | Raycast **Browser Extension** (tab content placeholder, browser tools) |
| **Store** | Slack, Linear, Notion, Jira, Spotify, 1Password, Chrome/Arc, Zoom, Todoist, Obsidian, VS Code, GitHub-style tools, design tools, translation, timers/Pomodoro, … |
| **AI protocol** | MCP servers; AI Extensions bridging store tools |
| **iOS** | Widgets, Control Center, Apple Shortcuts, Share Extension, custom keyboard |
| **Not a full Mail/Notes replacement** | Notes is Raycast’s own; Mail/Reminders typically via extensions or system |

---

## 3. Keyboard shortcuts & interaction model

**Philosophy:** Keyboard-first; mouse optional. Action Panel discovers capabilities. Emacs nav on by default; optional Vim.

### Global
| Shortcut | Action |
|---|---|
| `⌘ Space` / `Alt Space` | Toggle Raycast |
| Per-command hotkeys | Launch anything globally |

### General
| Shortcut | Action |
|---|---|
| `Esc` | Back / close |
| `⌘ Esc` / `⇧ Esc` | Pop to Root |
| `⌘ W` / `Ctrl W` | Close window |
| `⌘ ,` / `Ctrl ,` | Settings |
| `⇧ ⌘ /` | User Guide |

### Lists / Root Search
| Shortcut | Action |
|---|---|
| `↑↓` | Navigate |
| `⌥↑/↓` | Page |
| `⌘↑/↓` | Section |
| `Ctrl N/P` | Emacs up/down |
| `↵` | Primary action |
| `⌘ K` | Action Panel |
| `⇧ Tab` | Parent directory (files) |
| `⌘ F` | Favorite |
| `⇧ ⌘↑/↓` | Reorder favorites |

### Actions / items
| Shortcut | Action |
|---|---|
| `⌘ ↵` / `⇧ ⌘ ↵` | Secondary / tertiary action |
| `⌘ O` / `⇧ ⌘ O` / `⌥ ⌘ O` | Open / Reveal / Open With |
| `⌘ Y` | Quick Look |
| `⌘ C/V` (+ Shift variants) | Copy/paste (incl. deeplink) |
| `Ctrl X` | Delete |

### Forms
`⌘ ↵` submit · `Tab` / `⇧ Tab` fields · `Esc` cancel

### AI Chat (subset)
Sidebar, search chats, send to chat (`⌘ J`), attachments, branch, model/creativity/reasoning, archive, folders, upvote/downvote

**Full list:** https://manual.raycast.com/keyboard-shortcuts.md

---

## 4. Recent product directions (2024–2026)

| Direction | Evidence |
|---|---|
| **Cross-platform (macOS + Windows + iOS)** | Raycast 2.0 rewrite (“X-Ray”); Windows client; iOS AI/Notes/Snippets/Quicklinks |
| **AI-native OS layer** | Quick AI, Chat, Agents, Skills, Memory, Screen Awareness, Dictation, MCP, AI Extensions |
| **BYOAI / local** | v2.2 (Sep 3 2026): Custom Providers, Ollama Local Models, OpenRouter — **Pro-gated** (stricter than v1) |
| **Custom file indexer** | Rust indexer + NTFS MFT on Windows; content search; leave Spotlight dependency |
| **Focus / attention** | Raycast Focus product |
| **Notes + Sync** | First-party notes; Cloud Sync categories expanded |
| **Enterprise governance** | SSO/SCIM, AI allow-lists, extension allow-lists, clipboard controls |
| **Extension platform maturity** | Cross-platform extensions; AI tools/evals; private team stores |
| **Monetization of AI** | Pro required for AI/Dictation post-Windows beta; Advanced AI tier |

**Key dates:**
- Late 2023: Windows rewrite planning begins (blog)  
- May 14, 2026: 2.0 public beta + architecture post  
- Aug 25, 2026: 2.0 out of beta (Windows changelog)  
- Sep 1, 2026: v2.1 Inline Emoji Picker  
- Sep 3, 2026: v2.2 BYO Model  

**Sources:** https://www.raycast.com/blog/a-technical-deep-dive-into-the-new-raycast · https://manual.raycast.com/new-in-v2.md · https://www.raycast.com/changelog · https://www.raycast.com/changelog/windows

---

## 5. Extension ecosystem summary

- **Public Store** + **private Team extensions**  
- Authoring: React views (List/Grid/Detail/Form) or script-style; menu bar extras (Mac)  
- Distribution: Store review pipeline; fork/contribute via GitHub workflows in docs  
- Adjacent Raycast products: [ray.so](https://ray.so), Icon Maker, Explore Snippets/Quicklinks/Prompts/Chat Presets, Glaze, Keyboard hardware, themes.ray.so  
- Docs hubs: Manual for users; Developers for API; Script Commands GitHub for shell automation  

---

## 6. Omnicast-relevant takeaways (parity map)

If Omnicast targets “Raycast for Omarchy Linux,” the highest-leverage parity layers are:

1. **Launcher core** — Root Search, frecency, aliases, hotkeys, Action Panel, favorites, fallbacks  
2. **UI primitives** — List / Detail / Grid / Form / Action Panel (extension SDK contract)  
3. **Built-ins** — Clipboard, Snippets, Quicklinks, Calculator, File Search, WM, Emoji, System commands  
4. **Script Commands** — lowest-friction automation before a full extension API  
5. **Deeplinks + global hotkeys** — OS integration surface  
6. **AI later / optional** — Raycast’s differentiation and monetization; Screen Awareness + Dictation + Agents/MCP are the current frontier  
7. **Store** — network effects; cross-platform React extensions are the modern Raycast bet  

---

## 7. Sources index (major claims)

| Topic | URL |
|---|---|
| Homepage / positioning | https://www.raycast.com |
| Pricing matrix | https://www.raycast.com/pricing |
| Manual hub / TOC | https://manual.raycast.com · https://manual.raycast.com/llms.txt |
| Full manual dump | https://manual.raycast.com/llms-full.txt |
| Quickstart | https://manual.raycast.com/quickstart |
| Keyboard shortcuts | https://manual.raycast.com/keyboard-shortcuts.md |
| Search / Root Search | https://manual.raycast.com/search-bar.md |
| Core features (per-page) | `/snippets` `/quicklinks` `/clipboard-history` `/notes` `/focus` `/file-search` `/window-management` `/calculator` `/calendar` `/emoji-symbols` `/screenshots` `/translate` `/navigation` |
| Power features | `/hyper-key` `/cloud-sync` `/dynamic-placeholders` `/system-commands` `/script-commands` `/themes` `/auto-quit` `/run` `/games` |
| AI | https://manual.raycast.com/ai · `/ai/*` |
| Billing | https://manual.raycast.com/billing.md |
| Teams / Enterprise | https://manual.raycast.com/teams.md · `/enterprise` |
| New in v2 | https://manual.raycast.com/new-in-v2.md |
| Changelog | https://www.raycast.com/changelog · `/changelog/windows` |
| Store | https://www.raycast.com/store |
| Developer API | https://developers.raycast.com · `/llms.txt` |
| UI primitives | https://developers.raycast.com/api-reference/user-interface.md |
| Deeplinks | https://developers.raycast.com/information/lifecycle/deeplinks.md |
| Script Commands repo | https://github.com/raycast/script-commands |
| 2.0 architecture | https://www.raycast.com/blog/a-technical-deep-dive-into-the-new-raycast |
| AI models | https://www.raycast.com/core-features/ai/models |
| Footer feature list | Raycast AI, Notes, Focus, Clipboard, WM, Snippets, File Search, Quicklinks, Calculator, Calendar, System, Emoji (site footer) |

---

*Note: Some marketing pages (e.g. `/pro`) returned errors during fetch; pricing + Manual remain authoritative. Feature availability can differ slightly by platform (macOS vs Windows vs iOS) and Free vs Pro—platform tags in the Manual (“Available on: …”, “Pro Exclusive”) are the source of truth.*

---

# APPENDIX A — UI/UX Research (full)


Structured findings from Raycast manuals, developer API (their de-facto design system), marketing/design references, engineering writeups, and reviewer commentary. Focus: **actionable parity principles**, not brand cloning.

---

## 1. Window geometry & layout zones

### Window geometry
| Aspect | Raycast pattern | Omnicast implication |
|---|---|---|
| Shape | Centered floating panel, continuous rounded corners (~12px), vibrancy/blur over desktop | Use platform blur (GTK/Qt/layer-shell) + continuous corner radius; avoid sharp/cardy chrome |
| Sizing | Interface Size: Default / Large / Larger (scales chrome + type together) | Ship 2–3 density scales, not free resize that breaks list rhythm |
| Modes | **Expanded** (search + list always) vs **Compact** (search-only when query empty; expands on type or ⌘K) | Compact is a first-class mode; expand must be flicker-free |
| Focus | Opens with search focused; Esc clears query then dismisses; blur can auto-collapse Compact | Same Esc ladder; never leave focus in a random widget |
| Position | Near top-center / above dock (team iterated on “where the bar lives”) | Prefer top-center; keep clear of Wayland panel/dock |

### Canonical layout zones (top → bottom)

```
┌─────────────────────────────────────────────────────────────┐
│ SEARCH BAR                                                  │
│  [icon]  query…          [searchBarAccessory / dropdown]   │
│  [inline argument fields when command needs args]           │
│  thin loading bar under search when isLoading               │
├──────────────────────────────┬──────────────────────────────┤
│ LIST / GRID                  │ DETAIL (optional)            │
│  Section title               │  markdown body               │
│  ▶ selected row              │  ─ or ─                      │
│    icon · title · subtitle   │  metadata panel (labels,     │
│    accessories (right)       │  tags, links, separators)    │
│  …                           │                              │
├──────────────────────────────┴──────────────────────────────┤
│ FOOTER / ACTION BAR                                         │
│  primary action label + ↵    ·    Actions ⌘K / Ctrl+K       │
│  (secondary hints: ⌘↵, etc.)                                │
└─────────────────────────────────────────────────────────────┘
         Action Panel overlays as searchable popup (⌘K)
```

**Zone rules**
1. **Search** is always the entry; placeholder text describes *what you can search in this context*.
2. **List** is the default body; sections group by meaning (Favorites, Apps, Commands, Recent Files…).
3. **Detail** is opt-in (`isShowingDetail`); when on, move accessories into detail—don’t duplicate.
4. **Footer** always shows: selected item’s primary action + “Actions” with shortcut—discoverability without opening the panel.
5. **Action Panel** is a second, searchable surface—not a context menu clone.

Sources: [Search Bar manual](https://manual.raycast.com/search-bar), [List API](https://developers.raycast.com/api-reference/user-interface/list), [Action Panel manual](https://manual.raycast.com/action-panel), [Settings / Appearance](https://manual.raycast.com/settings)

---

## 2. Visual language

### App chrome (launcher itself)
- **Material**: Native vibrancy / frosted glass so the launcher feels *on top of the desktop*, not a solid dialog. Marketing site uses glass-blur nav; app uses system materials (including Liquid Glass on newer macOS).
- **Density**: Quiet, high-information list rows—icon + title + optional subtitle + right accessories. Selection is a full-row highlight (system accent / soft fill), not a left bar gimmick.
- **Icons**: Consistent SF Symbols / built-in Icon set for actions & chrome; app icons for applications. Never mix “some rows have icons, some don’t” in the same action list.
- **Badges / tags**: Alias shown as a small tag next to the command name; metadata uses colored tags (`TagList`).
- **Typography**: Clean sans (marketing: Inter). App follows system UI font. Hierarchy = title (primary) / subtitle (secondary, muted) / accessory (tertiary).
- **Spacing**: Tight list rhythm; section headers with breathing room; hairline separators between action groups—not heavy cards.
- **Selection & keyboard chrome**: Shortcuts rendered as keycaps on the **right** of every actionable row (results + action panel).

### Marketing site (brand, not launcher chrome)
- Near-black canvas (`#040506` / `#07080a`), coral brand `#ff6363` used sparingly.
- Elevation via hairline borders + multi-layer inset shadows (“keyboard key” / pressed chrome), not purple glow or floating card stacks.
- **Lesson for Omnicast**: launcher chrome should feel **OS-native + power-tool**; brand red is optional accent, not the whole UI.

Sources: [Blake Crosley design guide](https://blakecrosley.com/guides/design/raycast), [Refero Raycast styles](https://styles.refero.design/style/3b6a17f0-3bdf-418c-a95e-0b89e5a8b2f8), [Duply DESIGN.md extract](https://duply.ai/raycast/design-md), [Raycast tech deep dive](https://www.raycast.com/) (summarized at [superopc](https://superopc.app/tutorial/raycast))

---

## 3. Micro-interactions & animation feel

What reviewers/engineers describe as “polished”:

| Behavior | Feel |
|---|---|
| Hotkey → visible | **&lt;50ms** perceived; UI paints before data |
| Show/hide | No blank flash, no stale frame; pre-render before alpha-in |
| Compact ↔ expanded | Content already rendered; window clips grow—no WebKit blank strip |
| List selection | Instant keyboard move; no hover-as-primary (desktop convention) |
| Loading | Thin bar under search (`isLoading`), not modal spinners |
| Success after close | **HUD** toast floating briefly (copy, paste, done) |
| In-window feedback | **Toast** (Animated → Success/Failure) with optional cancel/copy-error actions |
| Delight | Brief, earned (confetti on achievements); playful empty copy; sounds optional |
| Motion budget | Short, purposeful; no slow “pretty” transitions that add latency |

**Native-feel checklist** (from Raycast’s own rewrite post):
- No `cursor: pointer` on desktop controls  
- Minimal web-style hover chrome on list rows  
- Popovers/tooltips as real OS windows that can overflow the launcher bounds  
- Settings in a separate window, not stuffed in the launcher  
- Avoid flicker on open/resize  

Sources: [Blake Crosley](https://blakecrosley.com/guides/design/raycast), [Tech deep dive summary](https://superopc.app/tutorial/raycast), YouTube: [“It’s Annoying How Good Raycast is”](https://www.youtube.com/watch?v=kHxgxgNHQR4), [Ultimate Raycast Deep Dive](https://www.youtube.com/watch?v=Kgn-e5a5uZA)

---

## 4. Keyboard-first navigation & discoverability

### Global grammar (muscle memory)
| Key | Behavior |
|---|---|
| `↵` | Primary action of selected item |
| `⌘↵` / `Ctrl↵` | Secondary action (or form submit) |
| `⌘K` / `Ctrl+K` | Open/close Action Panel |
| `Esc` | Close panel / go back / clear query / dismiss window (ladder) |
| `↑` `↓` | Move selection |
| `⌘↑/↓` | Jump sections |
| `⌥↑/↓` | Page jump |
| `Backspace` (empty query) | Navigate back (deep views) |
| `⇧Tab` | Parent directory (file nav) |
| `⌘,` | Settings |
| `⌘F` | Favorite |
| Type while Action Panel open | Fuzzy-filter actions |

### Discoverability patterns
1. **Footer always shows** primary action name + `↵` and `Actions` + `⌘K`.
2. **Shortcuts inline** on every action—learning by exposure, not docs.
3. Habit cue: “When unsure, press ⌘K.”
4. Optional Vim bindings in settings (don’t steal Ctrl+K from Action Panel unless remapped carefully).
5. Placeholder text documents current search scope.

Source: [Keyboard Shortcuts manual](https://manual.raycast.com/keyboard-shortcuts), [Action Panel](https://manual.raycast.com/action-panel), [Search Bar](https://manual.raycast.com/search-bar)

---

## 5. Search UX

### Root search vs deep views
- **Root Search**: global index—apps, commands, files, calendar, calculator, URLs, colors, settings, AI commands, etc.
- **Deep view**: after Enter on a command—List / Grid / Detail / Form with its own search bar (often filtering that view only).
- **Pop to Root**: timed return to root after inactivity (user preference).
- Navigation stack: `Action.Push` / Esc / Backspace empty-query to go back.

### Ranking (documented priority)
1. Exact alias match  
2. Alias prefix match  
3. Title fuzzy score  
4. Subtitle + keywords  
5. **Frecency** (frequency × recency; also learns query→result pairs)  

Also: Reset Ranking per item; Favorites pin above everything when query empty; sensitivity Low/Medium/High.

### Sections & empty states
- Empty query: Favorites, recent files, today’s calendar events, suggested commands.
- No matches: customizable empty-state commands at bottom of Root Search; in extensions use `List.EmptyView` (icon + title + description + optional CTA).
- **Anti-flicker rule**: never show “No results” while `isLoading` and query empty—show loading instead.
- Instant tools in-bar: calculator, URL detect, color convert—results appear as first-class rows.

### Filters
- `searchBarAccessory` = dropdown on right of search (`⌘P` to open)—second filter axis (status, project, category).
- Built-in fuzzy on `title` + `keywords`; opt out with `filtering={false}` + throttled `onSearchTextChange` for remote search.
- Pagination with placeholder skeleton rows at bottom.

Sources: [Search Bar](https://manual.raycast.com/search-bar), [List API](https://developers.raycast.com/api-reference/user-interface/list), [Settings empty-state commands](https://manual.raycast.com/settings), changelog frecency notes

---

## 6. Action Panel UX patterns

### Structure
1. **Primary** at top (= what Enter does)—Open / Run Command / etc.  
2. **Named sections**: Favorites, Configure, Deeplink, Manage, extension-specific groups.  
3. **Search field**: “Search for actions…” — fuzzy; searching flattens sections.  
4. **Submenus** (`…` in title): Configure Command → Set Hotkey / Set Alias; Open With…  
5. **Inline mini-views** inside panel (hotkey recorder, alias text field).  
6. **Destructive** style (red) for irreversible actions; confirm when needed.  
7. Esc backs out of submenu, then closes panel.

### Authoring conventions (store guidelines)
- Title Case: `Open in Browser`, `Copy to Clipboard`  
- Ellipsis `…` for anything that opens a submenu or needs more input  
- Icons consistent across the panel (all or none in a group)  
- Don’t repeat parent name in submenu children (`Low` not `Set Priority Low`)

### Dual path
- Power users trigger actions via shortcuts without opening the panel.  
- New users open panel once, see shortcut on the right, graduate to shortcuts.

Sources: [Action Panel manual](https://manual.raycast.com/action-panel), [Actions API](https://developers.raycast.com/api-reference/user-interface/actions), [Prepare for Store](https://developers.raycast.com/basics/prepare-an-extension-for-store)

---

## 7. Form / argument collection UX

### Two levels of input
**A. Command arguments (≤3) in Root Search**  
- Types: `text`, `password`, `dropdown`  
- Appear as fields in the search-bar area when a command needing args is selected  
- Left/Right arrows move between fields; alias + space focuses first arg  
- Required args before optional in manifest order  

**B. Full Form view**  
- Vertical labeled fields: TextField, PasswordField, TextArea, Checkbox, Dropdown, DatePicker, TagPicker, FilePicker, Separator, Description  
- Validation: set `error` on blur; clear on change; Submit blocked while errors exist (`useForm`)  
- Submit via `Action.SubmitForm` / `⌘↵`  
- Optional **drafts** (preserve values when leaving; drop on submit; never draft passwords)  
- Optional `Form.LinkAccessory` in nav bar  

**Principle**: Prefer arguments for 1–3 scalar inputs so users never leave Root Search; reserve Form for multi-field creation/editing.

Sources: [Search Bar — Command Arguments](https://manual.raycast.com/search-bar), [Form API](https://developers.raycast.com/api-reference/user-interface/form), Arguments section in [developers docs](https://developers.raycast.com/)

---

## 8. Detail pane / markdown / metadata

### Standalone Detail
- Left/main: CommonMark (images, LaTeX, custom image size/tint query params)  
- Right: `Detail.Metadata` — Label, TagList, Link, Separator  
- Top loading bar when async  
- Actions still via Action Panel / footer  

### List + Detail split
- `isShowingDetail` toggles right pane; toggle can be an Action + cached preference  
- `List.Item.Detail`: markdown top + metadata bottom (File Search / Clipboard / Contacts pattern)  
- When detail shown: **don’t** also show row accessories  

Sources: [Detail API](https://developers.raycast.com/api-reference/user-interface/detail), [List.Item.Detail](https://developers.raycast.com/api-reference/user-interface/list)

---

## 9. Why Raycast feels polished vs Alfred / Spotlight / Rofi

| Dimension | Raycast | Alfred | Spotlight | Typical Rofi |
|---|---|---|---|---|
| Visual system | One enforced design system for core + extensions | Powerful but older/utilitarian chrome | System-native, shallow | Themeable, inconsistent |
| Discoverability | Footer + ⌘K + inline shortcuts | Powerpack workflows; steeper | Minimal | Keybinds often undocumented |
| Extensibility UX | React UI components = identical List/Form/Actions | Script/workflow DIY | Shortcuts only | Scripts + raw rows |
| Feedback | HUD + Toast + loading bar | Varies | Minimal | Usually none |
| Learning | Frecency + aliases + favorites | Excellent once customized | Weak | None unless scripted |
| Personality | Modern 2020s UI, playful empties | Classic power-user | Invisible | Aesthetic only if themed |
| Speed feel | Sub-50ms + async paint | Often fastest raw launch | Fast, noisy results | Fast if configured |

Reviewer consensus ([DevToolReviews](https://www.devtoolreviews.com/reviews/raycast-vs-alfred-vs-spotlight), [Pickuma](https://pickuma.com/for-dev/vs-raycast-vs-alfred/), YouTube above): Raycast wins on **cohesive modern UI + out-of-box completeness + discoverability**; Alfred still praised for raw speed/custom workflows; Spotlight for zero-config basics; Rofi for Linux flexibility without productized UX.

**“Genuine & intuitive” comes from**:
1. Platform-native materials and shortcut conventions  
2. One interaction grammar everywhere (Enter / ⌘K / Esc)  
3. Extensions can’t invent random UIs—API enforces List/Form/Detail/Actions  
4. Instant UI, async data  
5. Progressive disclosure (footer → panel → shortcuts)  

---

## 10. Concrete Omnicast parity principles

### P0 — Without these it won’t feel like Raycast
1. **Single floating launcher** with blur/vibrancy, continuous corners, search always focused on open.  
2. **Layout zones**: Search → List (±Detail) → Footer action hints.  
3. **Enter = primary; Ctrl+K = Action Panel; Esc ladder** implemented consistently in root and deep views.  
4. **Action Panel**: searchable, sectioned, shortcuts on the right, submenus with `…`, destructive styling.  
5. **Footer always visible**: `Open ↵` · `Actions Ctrl+K` (labels match real primary).  
6. **Frecency ranking** + Favorites section + aliases + Reset Ranking.  
7. **Paint UI first** (`isLoading` bar); never flash empty state while loading.  
8. **HUD confirmations** after dismiss (Copied, Pasted, Done).  

### P1 — Parity polish
9. Compact mode (search-only → expand on type / action panel).  
10. Interface size scale (Default / Large / Larger).  
11. Inline command arguments (≤3) in search bar; Forms for complex input.  
12. List sections, accessories, keywords, EmptyView with CTA.  
13. Detail + Metadata (markdown + label/tag/link/separator).  
14. Search bar dropdown accessory for secondary filters.  
15. Toast for in-window async/errors (with cancel / copy error).  
16. Title Case actions; consistent icons; no mixed icon rows.  

### P2 — “Genuine” Linux-native feel (Raycast’s own lesson)
17. Match **desktop** conventions (no web pointer cursor, restrained hover).  
18. Popovers that can escape the launcher window bounds.  
19. Settings as separate window.  
20. Flicker-free show/hide and compact expand (pre-render).  
21. Extension/plugin UI constrained to the same components so third-party feels first-party.  
22. Personality in empty states and copy—without adding latency.  

### Explicit Linux adaptations
- Map ⌘ → Ctrl (Raycast already documents Ctrl on Windows).  
- Use system accent + Adwaita/Qt icon themes where appropriate; keep a single built-in icon set for actions.  
- Layer-shell / blur: prefer real backdrop blur over fake translucent fill.  
- Vs Rofi: win on **discoverability + action panel + feedback + ranking**, not on theme count.

---

## Sources (URLs)

### Official
- https://manual.raycast.com/search-bar  
- https://manual.raycast.com/action-panel  
- https://manual.raycast.com/keyboard-shortcuts  
- https://manual.raycast.com/settings  
- https://developers.raycast.com/api-reference/user-interface  
- https://developers.raycast.com/api-reference/user-interface/list  
- https://developers.raycast.com/api-reference/user-interface/detail  
- https://developers.raycast.com/api-reference/user-interface/form  
- https://developers.raycast.com/api-reference/user-interface/actions  
- https://developers.raycast.com/api-reference/feedback/toast  
- https://developers.raycast.com/basics/prepare-an-extension-for-store  
- https://developers.raycast.com/information/best-practices  

### Design / engineering commentary
- https://blakecrosley.com/guides/design/raycast  
- https://styles.refero.design/style/3b6a17f0-3bdf-418c-a95e-0b89e5a8b2f8  
- https://duply.ai/raycast/design-md  
- https://superopc.app/tutorial/raycast (Raycast 2.0 hybrid-stack / “feel native” deep dive summary)  

### Comparative reviews
- https://www.devtoolreviews.com/reviews/raycast-vs-alfred-vs-spotlight  
- https://pickuma.com/for-dev/vs-raycast-vs-alfred/  
- https://tech-insider.org/raycast-vs-alfred-2026/  
- https://www.theverge.com/23170431/raycast-how-to-macos-search-extensions-alfred-spotlight  

### Video (UX feel / polish)
- https://www.youtube.com/watch?v=kHxgxgNHQR4 — *It’s Annoying How Good Raycast is*  
- https://www.youtube.com/watch?v=Kgn-e5a5uZA — *Ultimate Raycast Deep Dive* (craft, latency, interaction experiments)  
- https://www.youtube.com/watch?v=Ei1RIZCrZN8 — Window management walkthrough (product density example)  

---

**Bottom line for Omnicast:** Raycast parity is less about coral accents and more about a **fixed zone layout**, **Enter/Ctrl+K/Esc grammar**, **footer-taught shortcuts**, **frecency + favorites**, **async-first loading**, and a **constrained component system** so every surface feels like one product.

---

# APPENDIX B — Clones & Alternatives (full)


**Verdict:** The “Raycast for Linux” gap is closing fast. **Vicinae** is the clear technical and traction leader (Raycast extension compatibility + native C++/Qt). Classic Linux tools (Rofi, Walker, Albert, Ulauncher) still win for *narrow, high-frequency workflows*. Cross-platform Tauri clones (Asyar, look, Gauntlet) prove demand but struggle with Wayland, polish, and ecosystem depth. On macOS, Raycast mostly won on *out-of-box product* vs Alfred’s *workflow engineering*; FOSS clones rarely beat that product surface.

Stars/activity below are approximate as of **2026-09-04**.

---

## Comparison table

| Project | Platform | Stack | Stars / maturity | Raycast-like? | Best for | Standout lesson |
|---|---|---|---|---|---|---|
| **[Vicinae](https://github.com/vicinaehq/vicinae)** | Linux (+ macOS) | C++23 / Qt Widgets + React/TS extensions | **~9.3k**, very active (commits same day) | ★★★★★ (partial Raycast store compat) | Closest full Raycast experience on Linux | Compatibility + batteries-included beats “pretty empty shell” |
| **[Walker](https://github.com/abenz1267/walker)** + [Elephant](https://github.com/abenz1267/elephant) | Linux (Wayland-first) | Rust / GTK4 + Go providers | **~3.0k**, active; rewritten Rust | ★★★☆☆ (UX modules, not Raycast API) | Hyprland/Niri power users; clipboard/windows/files | Provider/daemon split = deep Linux integration |
| **[Albert](https://github.com/albertlauncher/albert)** | Linux | C++ / Qt + Python plugins | **~8.0k**, mature (since 2014) | ★★★☆☆ | Desktop-agnostic plugin launcher | Longevity without Raycast-grade UX/store |
| **[Ulauncher](https://github.com/Ulauncher/Ulauncher)** | Linux | Python / GTK | **~4.5k**, mature | ★★☆☆☆ | Friendly fuzzy launcher + extensions | Approachable ≠ “command center” |
| **[Rofi](https://github.com/davatorium/rofi)** | Linux (X11; Wayland improving) | C | **~16.4k**, industry default | ★☆☆☆☆ | Scripts, dmenu, window switcher | Scriptability > product polish for Linux elites |
| **[Wofi](https://hg.sr.ht/~scoopta/wofi)** | Wayland | C / GTK3 | Niche | ★☆☆☆☆ | Rofi-like on Sway/Hyprland | Wayland port ≠ feature parity |
| **[Anyrun](https://github.com/anyrun-org/anyrun)** | Wayland | Rust / GTK4 | **~1.3k** | ★★☆☆☆ | Customizable wlroots runners | Plugin `.so` model, compositor-tied |
| **[Flare](https://github.com/ByteAtATime/flare)** | Linux | Tauri / Svelte / Rust | **~1.5k**, **unmaintained** | ★★★★☆ (compat goal) | Historical PoC | Dogfood or die; redirects users to Vicinae |
| **[Backslash](https://github.com/backslash-app/backslash)** | Linux | TypeScript (Electron-ish) | **~272**, alpha, slow | ★★★☆☆ | Humor + plugins experiment | Positioning alone ≠ traction |
| **[Hamr](https://github.com/stewart86/hamr)** | Wayland | Rust / GTK4 | **~340**, **maintenance mode** | ★★★☆☆ | Any-language JSON plugins | Single-maintainer risk |
| **[Beam](https://github.com/krishkalaria12/beam)** | Linux | Tauri v2 / React | **~5**, early | ★★★★☆ (claims Raycast runtime) | Watchlist only | Feature checklist ≠ product |
| **[Sol](https://github.com/ospfranco/sol)** | macOS | React Native macOS | **~3.1k**, active | ★★★☆☆ | Free local Raycast-lite | Batteries-in-core, no store dependency |
| **[Asyar](https://github.com/Xoshbin/asyar)** | macOS / Win / Linux X11 | Tauri / Rust / Svelte 5 | **~701**, active | ★★★★☆ | Cross-platform Raycast ambition | Wayland hole kills “cross-platform” claim |
| **[look](https://github.com/kunkka19xx/look)** | macOS / Win / Linux | SwiftUI + Tauri/Rust | **~828**, young/active | ★★★☆☆ | Local-first, no Electron | Anti-store as brand; thinner power features |
| **[Gauntlet](https://github.com/project-gauntlet/gauntlet)** | Cross-platform | Rust / iced + Deno React plugins | **~821**, slower lately | ★★★★☆ (own React API) | Sandboxed plugin architecture | Deno perms model is steal-worthy |
| **[Loungy](https://github.com/MatthiasGrandl/loungy)** | macOS (+ rough Linux) | Rust / GPUI | **~1.7k**, **archived** | ★★★☆☆ | Native-feel experiment | No extension system → stalled |
| **[Wox](https://github.com/Wox-launcher/Wox)** | Win / mac / Linux | Go | **~27k**, long-lived | ★★★☆☆ | Cross-platform “simply works” | Ecosystem age ≠ Raycast UX |
| **[Flow Launcher](https://github.com/Flow-Launcher/Flow.Launcher)** | Windows | C# | **~15.5k**, very active | ★★★★☆ | Windows power users + Everything | Plugin depth without commercial polish |
| **[Ueli](https://github.com/oliverschwendener/ueli)** | Cross-platform | TypeScript | **~4.6k** | ★★☆☆☆ | Simple keystroke launcher | Survived by staying narrow |
| **Alfred** | macOS | Native | Commercial | ★★★★☆ | Workflow automation | Depth for power users; free tier weak vs Raycast |
| **Spotlight** | macOS | Native | Built-in | ★★☆☆☆ | Zero-setup search | Floor, not ceiling |
| **LaunchBar** | macOS | Native | Commercial (since ’96) | ★★★☆☆ | Instant Send, adaptive ranking | Speed/habit over ecosystem |
| **Quicksilver** | macOS | Obj-C (OSS) | Niche / aging | ★★☆☆☆ | Subject–verb–object model | Interaction model innovated; product didn’t modernize |
| **PowerToys Command Palette** | Windows | C# / WinUI | Microsoft | ★★★☆☆ | Native-feeling Start replacement | Integration path ≠ all-in-one hub |
| **Raycast (Windows beta)** | Windows | Proprietary | Commercial | ★★★★★ | Raising the bar vs Flow/PT | Clipboard/emoji polish matters |

---

## Deep dives (best attempts)

### 1. Vicinae — the one that “got there”

| | |
|---|---|
| **URL** | https://github.com/vicinaehq/vicinae · https://docs.vicinae.com |
| **Platform** | Linux primary; macOS progressing |
| **Stack** | C++23, Qt Widgets (not QML), custom virtualized list; React/TS extensions via custom reconciler; script commands; dmenu mode |
| **Traction** | ~**9.3k★**, ~281 forks, Show HN (~181 pts), commits through 2026-09-04 |

**Got right**
- **Batteries included:** apps, clipboard, files, calculator, emoji, window switching, snippets, fonts, volume, browser tabs — Raycast’s “day-one surface.”
- **Raycast extension compatibility** (partial) + own store — instant ecosystem leverage.
- **Native performance narrative** (CPU/idle-first caching) that Linux users believe.
- **Script commands + dmenu** — FOSS-friendly escape hatches Raycast lacks.
- Unlocks theming / window APIs Raycast gates.

**Got wrong / limits**
- Extension parity incomplete; macOS-specific extensions break (AppleScript, hardcoded `/Applications`, native binaries).
- Still “not Raycast level” per author; extension ecosystem small vs store.
- Qt Widgets choice is powerful but harder for casual contributors than web UI.

**Omnicast lessons**
1. **Ship 6–8 core modules polished** before chasing a huge store.
2. **Compatibility with an existing extension API is a growth hack** — but expect 60–80% fidelity, document gaps.
3. Prefer **native shell + declarative extension UI** (Vicinae’s pattern) over full Electron.
4. Linux users forgive incomplete clones if **clipboard + windows + scripts** feel instant.

---

### 2. Walker + Elephant — “good enough for 1–2 workflows” champion

| | |
|---|---|
| **URL** | https://github.com/abenz1267/walker · https://walkerlauncher.com |
| **Platform** | Linux, Wayland (Hyprland/Niri/Sway sweet spot) |
| **Stack** | Walker UI: Rust/GTK4; Elephant: Go daemon + protobuf/unix socket providers |
| **Traction** | ~**3.0k★**; popular in ricing/Omarchy-adjacent communities |

**Got right**
- **Provider prefixes** (`:` clipboard, `/` files, `>` runner, `=` calc) — mode switching without menus.
- **Service + socket** for near-zero invoke latency.
- Clipboard, windows, snippets, passwords, wireplumber as **installable providers** — compose your Raycast from packages.
- dmenu mode + custom menus — scripting culture preserved.
- Provider **sets** (dev vs productivity keybinds) = workflow-specific launchers.

**Got wrong / limits**
- Setup friction: empty UI if Elephant/providers missing (“waiting for elephant”).
- Docs lagged during Go→Rust rewrite.
- Not a product for GNOME/casual users; compositor-specific feel.
- No Raycast extension story.

**Omnicast lessons**
1. **Separate search backend from UI** — enables multiple frontends and headless use.
2. Make **clipboard / window focus / runner** first-class with dedicated hotkeys, not buried modes.
3. Package providers so “clipboard-only” install is a supported path.
4. Empty-state UX must diagnose missing backend (Walker’s biggest newcomer failure).

---

### 3. Albert — mature Linux “Alfred,” not Raycast

| | |
|---|---|
| **URL** | https://github.com/albertlauncher/albert · https://albertlauncher.github.io |
| **Platform** | Linux, desktop-agnostic |
| **Stack** | C++/Qt + Python extensions |
| **Traction** | ~**8.0k★**, since 2014, still maintained |

**Got right**
- Plugin architecture that aged well; broad DE support.
- Triggers (`files*`, `cq` for CopyQ) for namespaced search.
- Snippets + system actions + web/SSH/docs plugins.

**Got wrong**
- UX feels dated vs Raycast’s single cohesive palette.
- Clipboard often via **CopyQ integration**, not first-class product.
- No curated store / AI / polished window manager story.
- Trigger/plugin config tax — Alfred-like, not Raycast-like.

**Omnicast lessons**
- Longevity without **unified product UX** still loses mindshare to Raycast.
- Don’t outsource clipboard to another app if that’s a hero feature.

---

### 4. Rofi / Wofi / Anyrun / Ulauncher — workflow primitives

**Rofi (~16.4k★, C)** — gold standard for scriptable menus, window switch, SSH, custom modes. Wins latency/RAM; loses “install and feel premium.”

**Wofi** — pragmatic Wayland `drun`/`dmenu`; CSS theming; thinner feature set.

**Anyrun (~1.3k★)** — Rust/GTK4 layer-shell runner; plugins as `.so`; Hyprland-centric; compositor features (randr) incomplete elsewhere.

**Ulauncher (~4.5k★)** — fuzzy, themes, Python extensions; higher memory/latency than Rofi; friendliest “Alfred-lite” for GNOME/Pop users; not a command center.

**What they’re good enough for (1–2 workflows)**

| Workflow | Best Linux pick | Notes |
|---|---|---|
| Clipboard history | Walker (`:` / `-m clipboard`) or Albert+CopyQ or cliphist+Rofi | Dedicated hotkey matters more than launcher brand |
| Scripts / custom menus | **Rofi/Wofi dmenu** | Still unbeaten for “stdin→stdout” glue |
| Window focus/switch | Rofi window mode / Walker windows / Vicinae | Wayland needs compositor APIs |
| App launch only | Ulauncher or Rofi `drun` | Don’t overbuild |
| Calculator/snippets | Walker / Albert / Vicinae | Snippets need accessibility/input injection on Wayland |

**Omnicast lessons**
- Linux power users will **compose** launchers; don’t fight Rofi for scripting — **interop with dmenu mode**.
- Winning means packaging the *composed* experience Vicinae/Walker aim for.

---

### 5. Sol — best FOSS “anti-subscription” on macOS

| | |
|---|---|
| **URL** | https://github.com/ospfranco/sol |
| **Platform** | macOS 14+ |
| **Stack** | React Native for macOS (not Electron) |
| **Traction** | ~**3.1k★**, Homebrew cask, ongoing releases |

**Got right**
- Core utilities in-product: clipboard, window mgmt, emoji, calendar, process killer, script runner — no Powerpack.
- Privacy / no telemetry / MIT — clear anti-Raycast-Pro positioning.
- Minimal config philosophy.

**Got wrong**
- No extension store; bash/AppleScript ceiling.
- RN-macOS raises purist perf skepticism.
- Stays “young/lacking” vs Raycast’s integrations (GitHub, Linear, AI Pro).

**Omnicast lessons**
- A strong free tier of **clipboard + windows + snippets** is table stakes.
- Without a **developer extension platform**, you cap at “nice utility,” not platform.

---

### 6. Asyar — most complete cross-platform Raycast *ambition*

| | |
|---|---|
| **URL** | https://asyar.org · https://github.com/Xoshbin/asyar |
| **Platform** | macOS, Windows 11, Linux **X11 only** (Wayland unsupported for global hooks) |
| **Stack** | Tauri + Rust + Svelte 5; sandboxed extensions; native daemon scheduling |
| **Traction** | ~**701★**, very active (2026-09) |

**Got right**
- Feature checklist matches Raycast: clipboard, snippets, AI BYOK, window layouts, portals, Pomodoro, store, deep links, silent AI replace.
- Privacy/local-first branding vs Raycast cloud/account.
- Extension sandbox + permissions — better security story than Raycast.

**Got wrong**
- **Wayland gap** is fatal for modern Linux credibility.
- Marketing claims vs real extension ecosystem size.
- Competing with Raycast on macOS *and* Flow on Windows is brutal for a small team.

**Omnicast lessons**
- Cross-platform is a product claim only if **global hotkeys + clipboard + window APIs** work on Wayland.
- Sandbox/permissions are a differentiator worth copying from Asyar/Gauntlet.
- Don’t ship “Raycast feature matrix” without 2–3 workflows that feel *better* than Raycast.

---

### 7. Gauntlet & Flare & Loungy — architectural cautionary tales

**Gauntlet (~821★)** — Rust + iced UI; **Deno-sandboxed React plugins**; git-URL plugin IDs (no central server required). Cross-platform intent. Pain: Wayland global shortcuts, slower recent activity, own API (not Raycast-compatible) → cold-start ecosystem.

**Flare (~1.5k★, unmaintained)** — Tauri Raycast-compatible Linux PoC. Author’s postmortem: **never dogfooded**, naive architecture, burnout. Explicitly points users to **Vicinae**. Lesson: compatibility demos without daily use don’t become products.

**Loungy (~1.7k★, archived)** — GPUI (Zed’s framework), beautiful native feel, clipboard/calculator/process killer; **no real extension system**; maintainer life change. Lesson: built-ins without extensibility plateau; recommend Gauntlet/Vicinae.

**Backslash (~272★)** — explicit “Raycast clone for Linux,” alpha, last meaningful push mid-2025. Lesson: brand/meme without velocity loses to Vicinae.

---

### 8. Windows / cross-platform baselines (competitive context)

**Flow Launcher (~15.5k★)** — deepest Windows plugin culture + Everything file search. Beats Start; loses to Raycast Windows on clipboard/emoji polish (per 2026 reviews).

**Wox (~27k★)** — historic cross-platform launcher; “works” more than “delights.”

**PowerToys Command Palette** — Microsoft-native path; lighter, fewer features; good hybrid with FancyZones.

**Raycast Windows beta** — raises expectations; Omnicast should assume users will compare clipboard UX to Raycast, not Flow.

**look (~828★)** — SwiftUI mac + Tauri Win/Linux; local-first, no daemon, no plugin store as *principle*. Interesting counter-position to Raycast-as-platform.

---

## macOS competitors vs Raycast (positioning)

| Tool | Vs Raycast | Steal / avoid |
|---|---|---|
| **Spotlight** | Free floor: apps/files/calc | Don’t compete on search alone |
| **Alfred** | Wins complex **workflows**, one-time Powerpack; loses free clipboard/WM/extensions | Workflow graph depth for power users |
| **LaunchBar** | Instant Send, adaptive ranking, low chrome | Habit learning & file actions |
| **Quicksilver** | Subject–action–object; OSS classic | Interaction model curiosity; dated UI |
| **Raycast** | Won on free built-ins + extension store + modern UI + AI | Extension DX (React) + root search of actions |

Raycast’s real product win: **one palette that absorbs 5 paid utilities** (clipboard, WM, snippets, emoji, API extensions) with a gentle curve. Alfred still owns *engineered* automation.

---

## Cross-cutting lessons for Omnicast

1. **Hero workflows > feature parity.** Clipboard, snippets, window management, script runner, calculator — polish these first. Linux “good enough” users live here today (Walker/Rofi/cliphist).
2. **Extension strategy fork:**  
   - *Compat* (Vicinae/Flare) → faster adoption, eternal API debt.  
   - *Own sandboxed API* (Gauntlet/Asyar) → cleaner long-term, cold start.  
   Hybrid (compat subset + native API) is what Vicinae is proving.
3. **Native > Electron** for launcher trust; **Tauri is the popular compromise** but Wayland/global input remains hard.
4. **Backend/UI split** (Elephant pattern) + **dmenu/script mode** = Linux credibility.
5. **Dogfood daily** (Flare’s stated failure mode) or don’t ship.
6. **Single-maintainer / no extensions** projects archive (Loungy, Flare, Hamr maintenance) — plan for extension-driven community or paid sustainability.
7. **Don’t leave clipboard to third-party apps** if it’s a marketing pillar.
8. **Wayland is not optional** for a Linux-first story in 2026.
9. **Store + discovery** is how Raycast stands out; OSS stores are weak — either invest or partner via Raycast-compat.
10. Windows competition is Flow depth vs Raycast polish; Omnicast needs a clear wedge (e.g. Linux-first quality, local-first, or workflow X).

---

## Suggested Omnicast competitive set (watch closely)

| Priority | Project | Why |
|---|---|---|
| P0 | **Vicinae** | Current category king for “Raycast on Linux” |
| P0 | **Walker/Elephant** | Best modular workflow architecture |
| P1 | **Asyar** | Feature ambition + Tauri patterns; Wayland risk |
| P1 | **Flow Launcher** | Windows plugin expectations |
| P1 | **Sol** | Free macOS utility bundle benchmark |
| P2 | **Gauntlet** | Deno sandbox / React reconciler ideas |
| P2 | **Albert / Rofi** | Installed-base & scripting interop |
| Archive study | **Flare, Loungy** | Failure modes (dogfood, extensions, burnout) |

---

## Sources

- GitHub APIs / READMEs: Vicinae, Walker, Elephant, Albert, Ulauncher, Rofi, Anyrun, Sol, Asyar, look, Gauntlet, Loungy, Flare, Backslash, Hamr, Beam, Wox, Flow Launcher, Ueli  
- https://docs.vicinae.com/  
- https://news.ycombinator.com/item?id=45188116 (Vicinae Show HN)  
- https://brunopaz.dev/blog/how-i-use-vicinae-command-launcher-for-linux/  
- https://walkerlauncher.com/docs/getting-started · advanced-usage  
- https://asyar.org/  
- https://terminalroot.com/meet-this-open-source-launcher-inspired-by-raycast/  
- https://fossforce.com/2025/07/streamline-your-linux-workflow-with-albert/  
- Alfred/Raycast/LaunchBar comparisons: Startupik, TextExpander, DownloadChaos, ShortcutDock (2025–2026)  
- Windows: PCMag, WindowsForum, HowToGeek, XDA (Flow / PowerToys / Raycast Windows)  
- ArchWiki List of applications/Other (launcher catalog)  
- Flare postmortem banner → Vicinae; Loungy archive banner → Gauntlet/Vicinae
---

# 8. Manhattan parity checklist for Omnicast

Mapped from Raycast core → Omnicast status (as of 2026-09-04 codebase).

| Raycast capability | Priority | Omnicast today | Notes |
|---|---|---|---|
| Root Search + sections | P0 | ✅ Partial | Apps, Omarchy cmds, scripts, power tools; needs frecency/aliases/favorites |
| Action Panel (`Ctrl+K`) searchable | P0 | ✅ Partial | Exists; needs fuzzy filter, sections, submenus, configure hotkey/alias inline |
| Footer primary + Actions hint | P0 | ✅ | Present |
| List / List+Detail / Grid / Form | P0 | ✅ | Components exist |
| Esc ladder (panel → pop → dismiss) | P0 | ✅ | Wired |
| HUD / Toast feedback | P0 | ❌ | Specced; not shipped |
| Clipboard History (types, pin, paste) | P0 | ✅ Strong | Omarchy-native bridge |
| Snippets with **in-app expansion** | P0 | ⚠️ Manager only | Need global keyword expand (Wayland input injection) |
| Quicklinks + placeholders | P1 | ❌ | High-value easy win |
| Calculator inline | P1 | ✅ Basic math | Needs units/currency/dates |
| Window Management | P1 | ✅ Basic hyprctl | Needs layouts, thirds/quarters, custom commands |
| File Search in Root | P1 | ❌ | Major Raycast v2 pillar |
| Emoji / Symbols picker | P1 | ❌ | |
| Script Commands modes (silent/compact/full/inline) | P0 | ⚠️ Partial | Parser + Form + Result; honor all modes |
| Themes sync | P1 | ✅ Omarchy | Free (Raycast gates custom themes on Pro) |
| AI Quick + Chat streaming | P0 (Phase 6) | ⚠️ UI mock | Wire Ollama/BYOK |
| Notes / Focus / Dictation / Calendar | P2 | ❌ | After Manhattan core |
| Extension Store (React) | P2 | ❌ | Script cmds first; consider Raycast-compat later |
| Deeplinks | P1 | ❌ | `omnicast://…` |
| Compact mode | P2 | ❌ | Raycast v2 polish |

**Manhattan definition of done:** A Raycast power user on Omarchy can do their daily loop (launch, clipboard, snippets expand, WM, scripts, calc, AI ask) without missing muscle memory — Action Panel grammar identical, feedback (HUD) present, ranking feels smart.

---

# 9. Berlin: how to beat Raycast on Omarchy

Raycast cannot (or will not) match these without abandoning its product shape:

| Advantage | Why it beats Raycast |
|---|---|
| **Hyprland IPC depth** | True tiling layouts, workspace jumps, special workspaces, monitors — not Accessibility-API approximations |
| **Omarchy as OS API** | 100+ `omarchy` routes live in Root Search; theme/`colors.toml` live sync free |
| **Local-first AI default** | Ollama/OpenRouter without Pro paywall for basic AI |
| **No cloud tax for power tools** | Unlimited clipboard, themes, custom WM free |
| **dmenu / script interop** | Preserve Linux glue culture (Walker/Rofi lesson) while wrapping it in Raycast UX |
| **Layer-shell + Kawase blur** | True compositor glass, not WebView vibrancy approximation |
| **Wayland-native input** | Clipboard + snippets designed for Wayland from day one (Asyar’s fatal gap) |

**Competitive watchlist (P0):** Vicinae (category king), Walker/Elephant (Omarchy-adjacent modular champion).

**Failure modes to avoid (from Flare/Loungy/Backslash):** no dogfooding, no extension story, single-maintainer burnout, “Raycast clone” branding without daily velocity.

---

# 10. Sources (master index)

### Official Raycast
- https://www.raycast.com · /pro · /store · /pricing · /enterprise · /core-features/*
- https://manual.raycast.com · /new-in-v2 · /action-panel · /clipboard-history · /snippets · /window-management · /ai · /keyboard-shortcuts · /llms.txt
- https://developers.raycast.com · UI List/Grid/Detail/Form/Action Panel
- https://github.com/raycast/script-commands
- https://www.raycast.com/changelog · /changelog/windows
- https://www.raycast.com/blog/a-technical-deep-dive-into-the-new-raycast

### Design / UX commentary
- https://blakecrosley.com/guides/design/raycast
- https://styles.refero.design/style/3b6a17f0-3bdf-418c-a95e-0b89e5a8b2f8
- YouTube: “It’s Annoying How Good Raycast is” (kHxgxgNHQR4), Ultimate Raycast Deep Dive (Kgn-e5a5uZA)

### Comparisons
- https://www.devtoolreviews.com/reviews/raycast-vs-alfred-vs-spotlight
- https://pickuma.com/for-dev/vs-raycast-vs-alfred/
- https://tech-insider.org/raycast-vs-alfred-2026/

### Linux / clones
- https://github.com/vicinaehq/vicinae · https://docs.vicinae.com · HN Show (id=45188116)
- https://github.com/abenz1267/walker · Elephant
- https://github.com/ByteAtATime/flare · https://github.com/backslash-app/backslash
- https://github.com/albertlauncher/albert · Ulauncher · Rofi · Anyrun
- https://github.com/ospfranco/sol · https://asyar.org · Gauntlet · Loungy
- https://wiki.hypr.land/Useful-Utilities/App-Launchers/

---

*End of research document. Appendices above contain full stream reports for features, UI/UX, and clones.*
