import QtQuick
import Quickshell
import Quickshell.Io
import "../services"
import "../components"

Item {
  id: root

  property var navStack: null
  property string filterText: ""

  signal requestActionPalette(var actions)
  signal requestDismiss()

  function loadWindowActions() {
    var items = [
      {
        id: "win-left",
        title: "Tile Left (50%)",
        subtitle: "Snap active window to the left half of the display",
        icon: "◧",
        badge: "Split",
        markdown: "### Snap Left Half\n\nResizes and moves the currently focused Hyprland window to cover the left **50%** of the active monitor.\n\n*Dispatcher:* `hyprctl dispatch movewindow l`",
        metadata: [
          { label: "Target Screen", value: "Current Monitor" },
          { label: "Width Ratio", value: "50%" }
        ],
        action: function() {
          root.hyprDispatch("movewindow l")
        },
        actions: [
          { title: "Tile Left (50%)", icon: "◧", shortcut: "↵", callback: function() { root.hyprDispatch("movewindow l") } },
          { title: "Tile Left (33%)", icon: "▎", callback: function() {} }
        ]
      },
      {
        id: "win-right",
        title: "Tile Right (50%)",
        subtitle: "Snap active window to the right half of the display",
        icon: "◨",
        badge: "Split",
        markdown: "### Snap Right Half\n\nResizes and moves the currently focused Hyprland window to cover the right **50%** of the active monitor.\n\n*Dispatcher:* `hyprctl dispatch movewindow r`",
        metadata: [
          { label: "Target Screen", value: "Current Monitor" },
          { label: "Width Ratio", value: "50%" }
        ],
        action: function() {
          root.hyprDispatch("movewindow r")
        },
        actions: [
          { title: "Tile Right (50%)", icon: "◨", shortcut: "↵", callback: function() { root.hyprDispatch("movewindow r") } }
        ]
      },
      {
        id: "win-full",
        title: "Toggle Fullscreen",
        subtitle: "Expand active window to fill the entire workspace",
        icon: "⛶",
        badge: "Layout",
        markdown: "### Fullscreen Toggle\n\nToggles fullscreen mode for the active window without borders or gaps.\n\n*Dispatcher:* `hyprctl dispatch fullscreen 1`",
        metadata: [
          { label: "State", value: "Monocle / Fullscreen" }
        ],
        action: function() {
          root.hyprDispatch("fullscreen 1")
        },
        actions: [
          { title: "Toggle Fullscreen", icon: "⛶", shortcut: "↵", callback: function() { root.hyprDispatch("fullscreen 1") } }
        ]
      },
      {
        id: "win-float",
        title: "Toggle Floating Window",
        subtitle: "Switch between dynamic tiling and floating modal",
        icon: "🪟",
        badge: "State",
        markdown: "### Toggle Floating\n\nDetaches the window from the tiling tree into a draggable floating overlay.\n\n*Dispatcher:* `hyprctl dispatch togglefloating`",
        metadata: [
          { label: "Mode", value: "Floating / Tiling" }
        ],
        action: function() {
          root.hyprDispatch("togglefloating")
        },
        actions: [
          { title: "Toggle Floating", icon: "🪟", shortcut: "↵", callback: function() { root.hyprDispatch("togglefloating") } },
          { title: "Center Window", icon: "🎯", callback: function() { root.hyprDispatch("centerwindow") } }
        ]
      },
      {
        id: "win-ws-next",
        title: "Move to Next Workspace",
        subtitle: "Send window to workspace +1",
        icon: "",
        badge: "Workspace",
        markdown: "### Move to Next Workspace\n\nTransfers the active window to the next sequential virtual workspace.\n\n*Dispatcher:* `hyprctl dispatch movetoworkspace +1`",
        metadata: [
          { label: "Direction", value: "+1 Workspace" }
        ],
        action: function() {
          root.hyprDispatch("movetoworkspace +1")
        },
        actions: [
          { title: "Move to +1", icon: "", shortcut: "↵", callback: function() { root.hyprDispatch("movetoworkspace +1") } }
        ]
      }
    ]

    listDetail.items = items
    listDetail.filter(filterText)
  }

  function hyprDispatch(arg) {
    Qt.createQmlObject('import Quickshell.Io; Process { command: ["hyprctl", "dispatch", "' + arg + '"]; running: true }', root)
    root.requestDismiss()
  }

  function filter(query) {
    root.filterText = query
    listDetail.filter(query)
  }

  function moveSelection(delta) {
    listDetail.moveSelection(delta)
  }

  function executeCurrent() {
    listDetail.executeCurrent()
  }

  function openActionPalette() {
    listDetail.openActionPalette()
  }

  ListDetailView {
    id: listDetail
    anchors.fill: parent

    onRequestActionPalette: actions => root.requestActionPalette(actions)
  }

  Component.onCompleted: {
    loadWindowActions()
  }
}
