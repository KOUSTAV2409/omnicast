// Curated Omarchy / Hyprland window actions (Lua-first; no classic setfloating).
.pragma library

// Full palette (WindowTilerView + root index subset).
// kind: omarchy | lua | snap
function allDefs() {
  return [
    // Berlin killer: exact float snaps via Hyprland Lua (Raycast can't do this on macOS)
    { id: "snap-left", title: "Snap Left Half", subtitle: "Float · left 50% of monitor", icon: "󰁍",
      kind: "snap", preset: "left" },
    { id: "snap-right", title: "Snap Right Half", subtitle: "Float · right 50% of monitor", icon: "󰁔",
      kind: "snap", preset: "right" },
    { id: "snap-top", title: "Snap Top Half", subtitle: "Float · top 50%", icon: "󰁝",
      kind: "snap", preset: "top" },
    { id: "snap-bottom", title: "Snap Bottom Half", subtitle: "Float · bottom 50%", icon: "󰁅",
      kind: "snap", preset: "bottom" },
    { id: "snap-left-third", title: "Snap Left Third", subtitle: "Float · left ⅓", icon: "󰁍",
      kind: "snap", preset: "left-third" },
    { id: "snap-center-third", title: "Snap Center Third", subtitle: "Float · middle ⅓", icon: "󰁔",
      kind: "snap", preset: "center-third" },
    { id: "snap-right-third", title: "Snap Right Third", subtitle: "Float · right ⅓", icon: "󰁔",
      kind: "snap", preset: "right-third" },
    { id: "snap-top-left", title: "Snap Top Left", subtitle: "Float · upper-left quarter", icon: "󰁃",
      kind: "snap", preset: "top-left" },
    { id: "snap-top-right", title: "Snap Top Right", subtitle: "Float · upper-right quarter", icon: "󰁜",
      kind: "snap", preset: "top-right" },
    { id: "snap-bottom-left", title: "Snap Bottom Left", subtitle: "Float · lower-left quarter", icon: "󰁂",
      kind: "snap", preset: "bottom-left" },
    { id: "snap-bottom-right", title: "Snap Bottom Right", subtitle: "Float · lower-right quarter", icon: "󰁩",
      kind: "snap", preset: "bottom-right" },
    { id: "snap-center", title: "Snap Center", subtitle: "Float · centered 60×70%", icon: "󰘕",
      kind: "snap", preset: "center" },
    { id: "snap-maximize", title: "Snap Maximize", subtitle: "Float · fill usable monitor", icon: "󰁌",
      kind: "snap", preset: "maximize" },

    { id: "om-pop", title: "Pop Window", subtitle: "Super+O · float & pin (toggle)", icon: "󰖯",
      kind: "omarchy", argv: ["omarchy-hyprland-window-pop"] },
    { id: "om-gaps", title: "Toggle Gaps", subtitle: "No gaps ↔ default gaps", icon: "󰝘",
      kind: "omarchy", argv: ["omarchy-hyprland-window-gaps-toggle"] },
    { id: "om-trans", title: "Toggle Transparency", subtitle: "Active window opacity", icon: "󰗔",
      kind: "omarchy", argv: ["omarchy-hyprland-window-transparency-toggle"] },
    { id: "om-tfs", title: "Tiled Fullscreen", subtitle: "Borderless tiled fullscreen", icon: "󰊓",
      kind: "omarchy", argv: ["omarchy-hyprland-window-tiled-fullscreen-toggle"] },
    { id: "om-ratio", title: "1-Window Ratio", subtitle: "Square aspect for single window", icon: "󰕮",
      kind: "omarchy", argv: ["omarchy-hyprland-window-single-square-aspect-toggle"] },
    { id: "om-layout", title: "Workspace Layout", subtitle: "Dwindle ↔ scrolling", icon: "󰕰",
      kind: "omarchy", argv: ["omarchy-hyprland-workspace-layout-toggle"] },
    { id: "om-width-save", title: "Save Window Width", subtitle: "Remember focused width", icon: "󰁎",
      kind: "omarchy", argv: ["omarchy-hyprland-window-width", "save"] },
    { id: "om-width-restore", title: "Restore Window Width", subtitle: "Apply saved width", icon: "󰁊",
      kind: "omarchy", argv: ["omarchy-hyprland-window-width", "restore"] },
    { id: "om-close-all", title: "Close All Windows", subtitle: "Close every client window", icon: "󰅖",
      kind: "omarchy", argv: ["omarchy-hyprland-window-close-all"] },
    { id: "win-float", title: "Toggle Float", subtitle: "Super+T · tile ↔ float", icon: "󰖲",
      kind: "lua", expr: "hl.dsp.window.float({ action = \"toggle\" })" },
    { id: "win-center", title: "Center Window", subtitle: "Center floating window", icon: "󰘕",
      kind: "lua", expr: "hl.dsp.window.center()" },
    { id: "win-full", title: "Fullscreen", subtitle: "Super+F", icon: "󰊓",
      kind: "lua", expr: "hl.dsp.window.fullscreen({ mode = \"fullscreen\" })" },
    { id: "win-max", title: "Maximize", subtitle: "Super+Alt+F · maximized", icon: "󰁌",
      kind: "lua", expr: "hl.dsp.window.fullscreen({ mode = \"maximized\" })" },
    { id: "win-scratch", title: "Move to Scratchpad", subtitle: "Super+Alt+S", icon: "󰖯",
      kind: "lua", expr: "hl.dsp.window.move({ workspace = \"special:scratchpad\", follow = false })" },
    { id: "win-ws-next", title: "Next Workspace", subtitle: "Move window e+1", icon: "󰁔",
      kind: "lua", expr: "hl.dsp.window.move({ workspace = \"e+1\" })" },
    { id: "win-ws-prev", title: "Previous Workspace", subtitle: "Move window e-1", icon: "󰁍",
      kind: "lua", expr: "hl.dsp.window.move({ workspace = \"e-1\" })" }
  ]
}

// Root-indexed subset (daily helpers + Berlin snaps)
function rootIndexIds() {
  return [
    "snap-left", "snap-right", "snap-center",
    "om-pop", "om-gaps", "om-trans", "om-tfs", "win-float", "win-full"
  ]
}

function rootIndexDefs() {
  var want = ({})
  var ids = rootIndexIds()
  for (var i = 0; i < ids.length; i++)
    want[ids[i]] = true
  var all = allDefs()
  var out = []
  for (var j = 0; j < all.length; j++) {
    if (want[all[j].id])
      out.push(all[j])
  }
  return out
}

function snapArgv(preset) {
  // Caller prefixes python3 + Paths.py("window_snap.py")
  return ["apply", String(preset || "")]
}
