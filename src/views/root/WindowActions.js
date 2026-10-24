// Curated Omarchy / Hyprland window actions (Lua-first; no classic setfloating).
.pragma library

// Full palette (WindowTilerView + root index subset).
function allDefs() {
  return [
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

// Root-indexed subset (daily helpers only).
function rootIndexIds() {
  return ["om-pop", "om-gaps", "om-trans", "om-tfs", "win-float", "win-full"]
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
