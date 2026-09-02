# Omnicast UI/UX Design System Specification

> **Design Target:** Raycast-Grade Visual Polish, Micro-Interactions & Omarchy Theming  

---

## 1. Window Geometry & Layering

* **Protocol**: `zwlr_layer_shell_v1`
* **Layer**: `Layer.Overlay`
* **Anchor**: Centered horizontally and slightly elevated vertically (offset `y: -15%` from exact screen center).
* **Dimensions**:
  * Default Width: `760px` (or `65%` of display width, clamped between `700px` and `880px`).
  * Default Height: `480px` (dynamic expansion up to `560px` for detail views).
* **Corner Radius**: `16px` outer window border radius, `8px` for internal items/badges.
* **Border**: `1px` subtle outer stroke with `12%` opacity white (`rgba(255, 255, 255, 0.12)`) on dark themes.

---

## 2. Acrylic Glassmorphism & Hyprland Blur

To achieve the signature frosted-glass background:
```ini
# Hyprland Layer Rules for Omnicast
layerrule = blur, omnicast
layerrule = ignorealpha 0.2, omnicast
layerrule = dimaround, omnicast
```
* **Background Color**: `rgba(20, 22, 28, 0.75)` with backdrop Kawase blur applied by Hyprland compositor.
* **Shadow**: Soft ambient drop shadow around the window (`radius: 32px`, `opacity: 0.45`).

---

## 3. Typography & Hierarchy

* **Primary Font**: Inter / SF Pro / Sans Serif (configured via Omarchy system font).
* **Monospace Font**: JetBrains Mono / Ghostty font.
* **Font Weights & Sizes**:
  * Search Bar Input: `18px`, Regular / Medium
  * Section Headers: `11px`, Bold, Uppercase, Tracking `0.08em`, Muted Color
  * Item Title: `14px`, Semi-Bold / Medium
  * Item Subtitle: `13px`, Regular, Muted
  * Item Badges/Tags: `11px`, Medium, with rounded pill background
  * Footer Hints: `12px`, Regular with high-contrast shortcut badges

---

## 4. Interaction Physics & Animation Curves

* **Navigation Push/Pop**:
  * Duration: `180ms`
  * Curve: `Easing.OutCubic` / `cubic-bezier(0.16, 1, 0.3, 1)`
  * Motion: Subtle horizontal slide (`12px`) + Opacity fade (`0.0` -> `1.0`).
* **Selection Change**:
  * Instant vertical highlight position interpolation (`80ms`, `Easing.OutQuad`).
* **Action Palette (`Ctrl+K`) Reveal**:
  * Scale from `0.96` to `1.0` + Opacity fade (`120ms`, `Easing.OutCubic`).

---

## 5. Keyboard Navigation Contract

| Key Combination | Action |
| :--- | :--- |
| `↑` / `↓` or `Ctrl+P` / `Ctrl+N` | Move active item selection up / down |
| `Enter` | Execute primary action on selected item |
| `Ctrl+K` or `Tab` | Open Action Palette for selected item |
| `Esc` | Pop current navigation view (or close window if at root) |
| `Ctrl+Backspace` | Clear search input |
| `Ctrl+1` ... `Ctrl+9` | Direct hotkey to numbered action inside Action Palette |
| `Ctrl+C` | Universal Copy action for selected item |
| `Ctrl+O` | Universal Open / Reveal action |
