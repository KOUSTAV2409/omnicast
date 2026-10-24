import QtQuick
import "../services"
import "../components"
import "root/WindowActions.js" as WindowActions

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

  function loadWindowActions() {
    var defs = WindowActions.allDefs()
    var items = []
    for (var i = 0; i < defs.length; i++) {
      var d = defs[i]
      var item = {
        id: d.id, title: d.title, subtitle: d.subtitle, icon: d.icon,
        badge: "", category: "Windows", primaryActionTitle: d.title, actions: []
      }
      item.action = (function(def) {
        return function() {
          if (def.kind === "snap")
            root.runSnap(def.preset, def.title)
          else if (def.kind === "omarchy")
            root.runOmarchy(def.argv, def.title)
          else
            root.runLua(def.expr, def.title)
        }
      })(d)
      item.actions = [{ title: d.title, icon: d.icon, shortcut: "↵", callback: item.action }]
      items.push(item)
    }
    allItems = items
    filter(filterText)
  }

  function runOmarchy(argv, title) {
    Hud.success(title || (selectedItem ? selectedItem.title : "Done"))
    root.requestDismiss()
    Exec.afterDismiss(argv, 80)
  }

  function runSnap(preset, title) {
    Hud.success(title || "Snapped")
    root.requestDismiss()
    Exec.afterDismiss(
      ["python3", Paths.py("window_snap.py"), "apply", String(preset || "")],
      100
    )
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
