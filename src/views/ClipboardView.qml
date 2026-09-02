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

  property Process clipLoader: Process {
    command: ["python3", "/home/iamkxyz/Projects/omnicast/src/backend/clipboard_manager.py", "list", root.filterText]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => root.handleData(text)
    }
  }

  function reloadData() {
    clipLoader.running = true
  }

  function handleData(raw) {
    try {
      var data = JSON.parse(raw || "[]")
      for (var i = 0; i < data.length; i++) {
        var item = data[i]
        item.action = (function(content) {
          return function() {
            root.copyAndPaste(content)
          }
        })(item.content)

        item.actions = [
          {
            title: "Copy & Paste into Active App",
            icon: "📋",
            shortcut: "↵",
            callback: (function(content) {
              return function() { root.copyAndPaste(content) }
            })(item.content)
          },
          {
            title: "Copy to Clipboard Only",
            icon: "📄",
            shortcut: "Ctrl+C",
            callback: (function(content) {
              return function() { root.copyOnly(content) }
            })(item.content)
          },
          {
            title: "Delete from History",
            icon: "🗑️",
            shortcut: "Del",
            callback: (function(cid) {
              return function() { root.deleteItem(cid) }
            })(item.id)
          }
        ]
      }
      listDetail.items = data
      listDetail.filter(root.filterText)
    } catch (e) {
      console.error("Error parsing clipboard JSON:", e)
    }
  }

  function copyAndPaste(text) {
    Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "wl-copy \'' + text.replace(/'/g, "'\\''") + '\' && wtype -M ctrl -k v -m ctrl 2>/dev/null || true"]; running: true }', root)
    root.requestDismiss()
  }

  function copyOnly(text) {
    Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "wl-copy \'' + text.replace(/'/g, "'\\''") + '\'"]; running: true }', root)
    root.requestDismiss()
  }

  function deleteItem(cid) {
    Qt.createQmlObject('import Quickshell.Io; Process { command: ["python3", "/home/iamkxyz/Projects/omnicast/src/backend/clipboard_manager.py", "delete", "' + cid + '"]; running: true }', root)
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

  ListDetailView {
    id: listDetail
    anchors.fill: parent

    onRequestActionPalette: actions => root.requestActionPalette(actions)
  }

  Component.onCompleted: {
    reloadData()
  }
}
