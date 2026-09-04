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

  readonly property var selectedItem: listDetail.selectedItem

  function loadWindowActions() {
    function mk(id, title, subtitle, icon, badge, md, meta, argv, primary) {
      return {
        id: id,
        title: title,
        subtitle: subtitle,
        icon: icon,
        badge: badge,
        primaryActionTitle: primary || title,
        markdown: md,
        metadata: meta,
        action: function() { root.hyprDispatch(argv) },
        actions: [
          { title: primary || title, icon: icon, shortcut: "↵", callback: function() { root.hyprDispatch(argv) } }
        ]
      }
    }

    var items = [
      mk("win-left", "Tile Left (50%)", "Snap focused window to left half", "◧", "Split",
         "### Left Half\n\nFloating snap to left 50% via Hyprland batch resize/move.",
         [{ label: "Ratio", value: "50%" }],
         ["--batch", "dispatch setfloating 1; dispatch resizeactive exact 50% 100%; dispatch moveactive exact 0 0"], "Tile Left"),
      mk("win-right", "Tile Right (50%)", "Snap focused window to right half", "◨", "Split",
         "### Right Half\n\nFloating snap to right 50%.",
         [{ label: "Ratio", value: "50%" }],
         ["--batch", "dispatch setfloating 1; dispatch resizeactive exact 50% 100%; dispatch moveactive exact 50% 0"], "Tile Right"),
      mk("win-top", "Tile Top (50%)", "Snap focused window to top half", "⬒", "Split",
         "### Top Half", [{ label: "Ratio", value: "50%" }],
         ["--batch", "dispatch setfloating 1; dispatch resizeactive exact 100% 50%; dispatch moveactive exact 0 0"], "Tile Top"),
      mk("win-bottom", "Tile Bottom (50%)", "Snap focused window to bottom half", "⬓", "Split",
         "### Bottom Half", [{ label: "Ratio", value: "50%" }],
         ["--batch", "dispatch setfloating 1; dispatch resizeactive exact 100% 50%; dispatch moveactive exact 0 50%"], "Tile Bottom"),
      mk("win-left-third", "Tile Left (33%)", "Left third of the monitor", "▎", "Split",
         "### Left Third", [{ label: "Ratio", value: "33%" }],
         ["--batch", "dispatch setfloating 1; dispatch resizeactive exact 33% 100%; dispatch moveactive exact 0 0"], "Tile Left 33%"),
      mk("win-center-third", "Tile Center (33%)", "Center third of the monitor", "▮", "Split",
         "### Center Third", [{ label: "Ratio", value: "33%" }],
         ["--batch", "dispatch setfloating 1; dispatch resizeactive exact 34% 100%; dispatch moveactive exact 33% 0"], "Tile Center"),
      mk("win-right-third", "Tile Right (33%)", "Right third of the monitor", "▍", "Split",
         "### Right Third", [{ label: "Ratio", value: "33%" }],
         ["--batch", "dispatch setfloating 1; dispatch resizeactive exact 33% 100%; dispatch moveactive exact 67% 0"], "Tile Right 33%"),
      mk("win-tl", "Top Left Quarter", "Quarter snap", "◰", "Quarter",
         "### Top Left", [{ label: "Ratio", value: "50%×50%" }],
         ["--batch", "dispatch setfloating 1; dispatch resizeactive exact 50% 50%; dispatch moveactive exact 0 0"], "Top Left"),
      mk("win-tr", "Top Right Quarter", "Quarter snap", "東北", "Quarter",
         "### Top Right", [{ label: "Ratio", value: "50%×50%" }],
         ["--batch", "dispatch setfloating 1; dispatch resizeactive exact 50% 50%; dispatch moveactive exact 50% 0"], "Top Right"),
      mk("win-bl", "Bottom Left Quarter", "Quarter snap", "◱", "Quarter",
         "### Bottom Left", [{ label: "Ratio", value: "50%×50%" }],
         ["--batch", "dispatch setfloating 1; dispatch resizeactive exact 50% 50%; dispatch moveactive exact 0 50%"], "Bottom Left"),
      mk("win-br", "Bottom Right Quarter", "Quarter snap", "◲", "Quarter",
         "### Bottom Right", [{ label: "Ratio", value: "50%×50%" }],
         ["--batch", "dispatch setfloating 1; dispatch resizeactive exact 50% 50%; dispatch moveactive exact 50% 50%"], "Bottom Right"),
      mk("win-center", "Center Window", "Center the focused window", "🎯", "Layout",
         "### Center", [{ label: "Dispatcher", value: "centerwindow" }],
         ["centerwindow"], "Center"),
      mk("win-full", "Toggle Fullscreen", "Fullscreen without borders", "⛶", "Layout",
         "### Fullscreen", [{ label: "Dispatcher", value: "fullscreen 1" }],
         ["fullscreen", "1"], "Fullscreen"),
      mk("win-float", "Toggle Floating", "Floating vs tiling", "🪟", "State",
         "### Toggle Floating", [{ label: "Dispatcher", value: "togglefloating" }],
         ["togglefloating"], "Toggle Float"),
      mk("win-max", "Maximize", "Maximize on current monitor", "⬜", "Layout",
         "### Maximize", [{ label: "Dispatcher", value: "fullscreen 0" }],
         ["fullscreen", "0"], "Maximize"),
      mk("win-ws-next", "Move to Next Workspace", "Send window to +1 workspace", "→", "Workspace",
         "### Next Workspace", [{ label: "Dispatcher", value: "movetoworkspace +1" }],
         ["movetoworkspace", "+1"], "Move +1"),
      mk("win-ws-prev", "Move to Previous Workspace", "Send window to -1 workspace", "←", "Workspace",
         "### Previous Workspace", [{ label: "Dispatcher", value: "movetoworkspace -1" }],
         ["movetoworkspace", "-1"], "Move -1"),
      mk("win-mon-next", "Move to Next Monitor", "Throw window to next display", "🖥️", "Monitor",
         "### Next Monitor", [{ label: "Dispatcher", value: "movewindow mon:+1" }],
         ["movewindow", "mon:+1"], "Next Monitor")
    ]

    listDetail.items = items
    listDetail.filter(filterText)
  }

  function hyprDispatch(argv) {
    // Dismiss first so Hyprland restores focus to the real client window.
    Hud.success("Window updated")
    root.requestDismiss()
    if (argv[0] === "--batch") {
      Exec.detached(["hyprctl", "--batch", argv[1]])
    } else {
      var cmd = ["hyprctl", "dispatch"]
      for (var i = 0; i < argv.length; i++)
        cmd.push(argv[i])
      Exec.detached(cmd)
    }
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

  Component.onCompleted: loadWindowActions()
}
