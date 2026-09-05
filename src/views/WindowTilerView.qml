import QtQuick
import "../services"
import "../components"

// Curated Omarchy / Hyprland window actions.
// Omarchy Hyprland is Lua-first: never use classic `dispatch setfloating` batches.
Item {
  id: root

  property var navStack: null
  property string filterText: ""
  property int selectedIndex: 0
  property var allItems: []
  property var filteredItems: []

  signal requestActionPalette(var actions)
  signal requestDismiss()

  readonly property var selectedItem: filteredItems.length > 0 && selectedIndex < filteredItems.length
                                      ? filteredItems[selectedIndex] : null

  function mkOmarchy(id, title, subtitle, icon, argv) {
    var item = {
      id: id, title: title, subtitle: subtitle, icon: icon,
      badge: "", category: "Windows", primaryActionTitle: title, actions: []
    }
    item.action = function() { root.runOmarchy(argv, title) }
    item.actions = [{ title: title, icon: icon, shortcut: "↵", callback: item.action }]
    return item
  }

  function mkLua(id, title, subtitle, icon, expr) {
    var item = {
      id: id, title: title, subtitle: subtitle, icon: icon,
      badge: "", category: "Windows", primaryActionTitle: title, actions: []
    }
    item.action = function() { root.runLua(expr, title) }
    item.actions = [{ title: title, icon: icon, shortcut: "↵", callback: item.action }]
    return item
  }

  function loadWindowActions() {
    allItems = [
      mkOmarchy("om-pop", "Pop Window", "Super+O · float & pin (toggle)", "󰖯",
                ["omarchy-hyprland-window-pop"]),
      mkOmarchy("om-gaps", "Toggle Gaps", "No gaps ↔ default gaps", "󰝘",
                ["omarchy-hyprland-window-gaps-toggle"]),
      mkOmarchy("om-trans", "Toggle Transparency", "Active window opacity", "󰗔",
                ["omarchy-hyprland-window-transparency-toggle"]),
      mkOmarchy("om-tfs", "Tiled Fullscreen", "Borderless tiled fullscreen", "󰊓",
                ["omarchy-hyprland-window-tiled-fullscreen-toggle"]),
      mkOmarchy("om-ratio", "1-Window Ratio", "Square aspect for single window", "󰕮",
                ["omarchy-hyprland-window-single-square-aspect-toggle"]),
      mkOmarchy("om-layout", "Workspace Layout", "Dwindle ↔ scrolling", "󰕰",
                ["omarchy-hyprland-workspace-layout-toggle"]),
      mkOmarchy("om-width-save", "Save Window Width", "Remember focused width", "󰁎",
                ["omarchy-hyprland-window-width", "save"]),
      mkOmarchy("om-width-restore", "Restore Window Width", "Apply saved width", "󰁊",
                ["omarchy-hyprland-window-width", "restore"]),
      mkOmarchy("om-close-all", "Close All Windows", "Close every client window", "󰅖",
                ["omarchy-hyprland-window-close-all"]),

      mkLua("win-float", "Toggle Float", "Super+T · tile ↔ float", "󰖲",
            "hl.dsp.window.float({ action = \"toggle\" })"),
      mkLua("win-center", "Center Window", "Center floating window", "󰘕",
            "hl.dsp.window.center()"),
      mkLua("win-full", "Fullscreen", "Super+F", "󰊓",
            "hl.dsp.window.fullscreen({ mode = \"fullscreen\" })"),
      mkLua("win-max", "Maximize", "Super+Alt+F · maximized", "󰁌",
            "hl.dsp.window.fullscreen({ mode = \"maximized\" })"),
      mkLua("win-scratch", "Move to Scratchpad", "Super+Alt+S", "󰖯",
            "hl.dsp.window.move({ workspace = \"special:scratchpad\", follow = false })"),
      mkLua("win-ws-next", "Next Workspace", "Move window e+1", "󰁔",
            "hl.dsp.window.move({ workspace = \"e+1\" })"),
      mkLua("win-ws-prev", "Previous Workspace", "Move window e-1", "󰁍",
            "hl.dsp.window.move({ workspace = \"e-1\" })")
    ]
    filter(filterText)
  }

  function runOmarchy(argv, title) {
    Hud.success(title || (selectedItem ? selectedItem.title : "Done"))
    root.requestDismiss()
    Exec.afterDismiss(argv, 80)
  }

  function runLua(expr, title) {
    Hud.success(title || (selectedItem ? selectedItem.title : "Done"))
    root.requestDismiss()
    Exec.afterDismiss(["hyprctl", "dispatch", expr], 80)
  }

  function filter(query) {
    root.filterText = query || ""
    if (!root.filterText.trim().length) {
      filteredItems = allItems
    } else {
      var scored = []
      for (var i = 0; i < allItems.length; i++) {
        var s = Fuzzy.itemScore(root.filterText, allItems[i])
        if (s > 0) scored.push({ item: allItems[i], score: s })
      }
      scored.sort(function(a, b) { return b.score - a.score })
      filteredItems = scored.map(function(x) { return x.item })
    }
    selectedIndex = filteredItems.length ? 0 : 0
  }

  function moveSelection(delta) {
    if (!filteredItems.length) return
    var next = selectedIndex + delta
    if (next < 0) next = filteredItems.length - 1
    if (next >= filteredItems.length) next = 0
    selectedIndex = next
    list.positionViewAtIndex(selectedIndex, ListView.Contain)
  }

  function executeCurrent() {
    if (selectedItem && typeof selectedItem.action === "function")
      selectedItem.action()
  }

  function openActionPalette() {
    if (selectedItem && selectedItem.actions)
      root.requestActionPalette(selectedItem.actions)
  }

  ListView {
    id: list
    anchors.fill: parent
    clip: true
    model: root.filteredItems
    spacing: Theme.rowSpacing
    boundsBehavior: Flickable.StopAtBounds

    delegate: ItemRow {
      width: list.width
      title: modelData.title
      subtitle: modelData.subtitle || ""
      iconText: modelData.icon || ""
      isSelected: index === root.selectedIndex
      onClicked: { root.selectedIndex = index }
      onDoubleClicked: { root.selectedIndex = index; root.executeCurrent() }
    }
  }

  EmptyState {
    anchors.centerIn: parent
    visible: root.filteredItems.length === 0
    title: "No window actions"
    subtitle: "Try pop, float, gaps, fullscreen…"
  }

  Component.onCompleted: loadWindowActions()
}
