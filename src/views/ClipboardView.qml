import QtQuick
import Quickshell
import Quickshell.Io
import "../services"
import "../components"

Item {
  id: root

  property var navStack: null
  property string filterText: ""
  property string activeCategory: "all" // "all", "pinned", "text", "code", "color", "url", "image"

  signal requestActionPalette(var actions)
  signal requestDismiss()

  // Selected item proxy
  readonly property var selectedItem: listDetail.selectedItem

  property Process clipLoader: Process {
    command: ["python3", "/home/iamkxyz/Projects/omnicast/src/backend/clipboard_manager.py", "list", root.filterText, root.activeCategory]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => root.handleData(text)
    }
  }

  function reloadData() {
    if (!clipLoader.running) {
      clipLoader.command = ["python3", "/home/iamkxyz/Projects/omnicast/src/backend/clipboard_manager.py", "list", root.filterText, root.activeCategory]
      clipLoader.running = true
    }
  }

  function handleData(raw) {
    try {
      var data = JSON.parse(raw || "[]")
      for (var i = 0; i < data.length; i++) {
        var item = data[i]
        item.action = (function(it) {
          return function() { root.copyAndPaste(it) }
        })(item)

        var actionsList = [
          {
            title: "Paste into Active App",
            icon: "📋",
            shortcut: "↵",
            callback: (function(it) {
              return function() { root.copyAndPaste(it) }
            })(item)
          },
          {
            title: "Copy to Clipboard",
            icon: "📄",
            shortcut: "Ctrl+C",
            callback: (function(it) {
              return function() { root.copyOnly(it) }
            })(item)
          },
          {
            title: item.isPinned ? "Unpin Item" : "Pin Item to Top",
            icon: "📌",
            shortcut: "Ctrl+P",
            callback: (function(it) {
              return function() { root.togglePin(it.raw_id) }
            })(item)
          }
        ]

        if (item.contentType === "url") {
          actionsList.push({
            title: "Open URL in Browser",
            icon: "🌐",
            shortcut: "Ctrl+O",
            callback: (function(urlStr) {
              return function() {
                Qt.createQmlObject('import Quickshell.Io; Process { command: ["xdg-open", "' + urlStr + '"]; running: true }', root)
                root.requestDismiss()
              }
            })(item.content)
          })
        } else if (item.contentType === "image") {
          actionsList.push({
            title: "Open in Image Viewer",
            icon: "🖼️",
            shortcut: "Ctrl+O",
            callback: (function(imgPath) {
              return function() {
                Qt.createQmlObject('import Quickshell.Io; Process { command: ["imv", "' + imgPath + '"]; running: true }', root)
                root.requestDismiss()
              }
            })(item.imagePath)
          })
        }

        actionsList.push({
          title: "Delete from History",
          icon: "🗑️",
          shortcut: "Del",
          callback: (function(cid) {
            return function() { root.deleteItem(cid) }
          })(item.raw_id)
        })

        actionsList.push({
          title: "Clear History (Keep Pinned)",
          icon: "🧹",
          shortcut: "Ctrl+Shift+Del",
          callback: function() { root.clearHistory() }
        })

        item.actions = actionsList
      }

      listDetail.items = data
      listDetail.filter(root.filterText)
    } catch (e) {
      console.error("Error parsing clipboard JSON:", e)
    }
  }

  function copyAndPaste(item) {
    if (item.contentType === "image" && item.imagePath) {
      Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "wl-copy --type image/png < \'' + item.imagePath + '\' && sleep 0.05 && wtype -M ctrl -k v -m ctrl 2>/dev/null || true"]; running: true }', root)
    } else {
      Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "wl-copy \'' + item.content.replace(/'/g, "'\\''") + '\' && sleep 0.05 && wtype -M ctrl -k v -m ctrl 2>/dev/null || true"]; running: true }', root)
    }
    root.requestDismiss()
  }

  function copyOnly(item) {
    if (item.contentType === "image" && item.imagePath) {
      Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "wl-copy --type image/png < \'' + item.imagePath + '\'"]; running: true }', root)
    } else {
      Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "wl-copy \'' + item.content.replace(/'/g, "'\\''") + '\'"]; running: true }', root)
    }
    root.requestDismiss()
  }

  function togglePin(cid) {
    Qt.createQmlObject('import Quickshell.Io; Process { command: ["python3", "/home/iamkxyz/Projects/omnicast/src/backend/clipboard_manager.py", "pin", "' + cid + '"]; running: true }', root)
    reloadData()
  }

  function deleteItem(cid) {
    Qt.createQmlObject('import Quickshell.Io; Process { command: ["python3", "/home/iamkxyz/Projects/omnicast/src/backend/clipboard_manager.py", "delete", "' + cid + '"]; running: true }', root)
    reloadData()
  }

  function clearHistory() {
    Qt.createQmlObject('import Quickshell.Io; Process { command: ["python3", "/home/iamkxyz/Projects/omnicast/src/backend/clipboard_manager.py", "clear"]; running: true }', root)
    reloadData()
  }

  function filter(query) {
    root.filterText = query
    reloadData()
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

  Column {
    anchors.fill: parent

    // Top Category Filter Tabs Bar
    Rectangle {
      width: parent.width
      height: 32
      color: "transparent"

      Row {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Repeater {
          model: [
            { id: "all", label: "All" },
            { id: "pinned", label: "📌 Pinned" },
            { id: "text", label: "📄 Text" },
            { id: "code", label: " Code" },
            { id: "color", label: "🎨 Colors" },
            { id: "url", label: "🌐 Links" },
            { id: "image", label: "🖼️ Images" }
          ]

          delegate: Rectangle {
            id: tabPill
            height: 22
            radius: 4
            width: tabText.implicitWidth + 14
            color: root.activeCategory === modelData.id ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.20) : (tabMouse.containsMouse ? Theme.itemHoverBackground : "transparent")
            border.color: root.activeCategory === modelData.id ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.50) : Theme.subtleBorder
            border.width: 1

            Text {
              id: tabText
              anchors.centerIn: parent
              text: modelData.label
              font.family: Theme.fontFamily
              font.pixelSize: 11
              font.weight: root.activeCategory === modelData.id ? Font.SemiBold : Font.Normal
              color: root.activeCategory === modelData.id ? Theme.accent : Theme.muted
            }

            MouseArea {
              id: tabMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.activeCategory = modelData.id
                root.reloadData()
              }
            }
          }
        }
      }

      // Bottom Divider
      Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: Theme.subtleBorder
      }
    }

    // Main List + Detail Pane
    Item {
      width: parent.width
      height: parent.height - 32

      ListDetailView {
        id: listDetail
        anchors.fill: parent
        onRequestActionPalette: actions => root.requestActionPalette(actions)
      }
    }
  }

  Component.onCompleted: {
    reloadData()
  }
}
