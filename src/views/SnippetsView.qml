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

  property Process snippetLoader: Process {
    command: ["python3", "/home/iamkxyz/Projects/omnicast/src/backend/snippet_manager.py", "list"]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => root.handleData(text)
    }
  }

  function reloadData() {
    snippetLoader.running = true
  }

  function handleData(raw) {
    try {
      var data = JSON.parse(raw || "[]")
      for (var i = 0; i < data.length; i++) {
        var item = data[i]
        item.action = (function(sid) {
          return function() { root.insertSnippet(sid) }
        })(item.id)

        item.actions = [
          {
            title: "Insert Snippet into Window",
            icon: "⚡",
            shortcut: "↵",
            callback: (function(sid) {
              return function() { root.insertSnippet(sid) }
            })(item.id)
          },
          {
            title: "Copy Snippet to Clipboard",
            icon: "📋",
            shortcut: "Ctrl+C",
            callback: (function(content) {
              return function() { root.copySnippet(content) }
            })(item.content)
          }
        ]
      }
      listDetail.items = data
      listDetail.filter(root.filterText)
    } catch (e) {
      console.error("Error parsing snippet JSON:", e)
    }
  }

  function insertSnippet(sid) {
    Qt.createQmlObject('import Quickshell.Io; Process { command: ["python3", "/home/iamkxyz/Projects/omnicast/src/backend/snippet_manager.py", "insert", "' + sid + '"]; running: true }', root)
    root.requestDismiss()
  }

  function copySnippet(text) {
    Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "wl-copy \'' + text.replace(/'/g, "'\\''") + '\'"]; running: true }', root)
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
    reloadData()
  }
}
