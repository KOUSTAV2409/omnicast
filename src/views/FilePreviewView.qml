import QtQuick
import Quickshell
import "../services"
import "../components"

Item {
  id: root

  property var navStack: null
  property string filePath: ""
  property string fileTitle: ""
  property var siblingPaths: []
  property int siblingIndex: -1
  property bool wideLayout: true

  signal requestActionPalette(var actions)
  signal requestDismiss()
  signal requestPushViewWithProps(string title, var component, var props)

  readonly property var selectedItem: ({
    primaryActionTitle: root.primaryLabel(),
    category: "File",
    badge: pane.kind || "File",
    actions: root.buildActions()
  })

  function primaryLabel() {
    if (pane.kind === "dir")
      return "Open Folder"
    if (pane.opener && pane.opener.title)
      return pane.opener.title
    return "Open"
  }

  function buildActions() {
    var acts = []
    acts.push({
      title: root.primaryLabel(),
      icon: "󰈔",
      shortcut: "↵",
      callback: function() { root.openExternal() }
    })
    if (siblingPaths && siblingPaths.length > 1) {
      acts.push({
        title: "Next File",
        icon: "›",
        callback: function() { root.goSibling(1) }
      })
      acts.push({
        title: "Previous File",
        icon: "‹",
        callback: function() { root.goSibling(-1) }
      })
    }
    acts.push({
      title: "Copy Path",
      icon: "",
      callback: function() {
        Exec.copyText(root.filePath)
        Hud.success("Copied path")
      }
    })
    acts.push({
      title: "Reveal in Folder",
      icon: "󰉋",
      callback: function() {
        if (pane.kind === "dir")
          Exec.openPath(root.filePath)
        else
          Exec.revealPath(root.filePath)
        root.requestDismiss()
      }
    })
    if (pane.kind !== "dir") {
      acts.push({
        title: "Open with xdg-open",
        icon: "󰏌",
        callback: function() {
          Ranking.bump("file-open-xdg")
          root.requestDismiss()
          Exec.openPath(root.filePath)
        }
      })
    }
    return acts
  }

  function openExternal() {
    Ranking.bump("file-open-external")
    root.requestDismiss()
    var argv = (pane.opener && pane.opener.argv) ? pane.opener.argv : null
    if (argv && argv.length)
      Exec.detached(argv)
    else
      Exec.openPath(root.filePath)
    Hud.success("Opening " + (root.fileTitle || root.filePath))
  }

  function goSibling(delta) {
    if (!siblingPaths || siblingPaths.length < 2)
      return
    var idx = siblingIndex
    if (idx < 0) {
      for (var i = 0; i < siblingPaths.length; i++) {
        if (siblingPaths[i] === filePath) { idx = i; break }
      }
    }
    if (idx < 0) idx = 0
    var next = (idx + delta + siblingPaths.length) % siblingPaths.length
    var p = siblingPaths[next]
    filePath = p
    fileTitle = p.split("/").pop()
    siblingIndex = next
    pane.filePath = ""
    pane.filePath = p
    pane.fileTitle = fileTitle
  }

  function executeCurrent() {
    openExternal()
  }

  function openActionPalette() {
    root.requestActionPalette(buildActions())
  }

  function moveSelection(delta) {
    // Left/right style: treat as sibling browse when available
    if (siblingPaths && siblingPaths.length > 1)
      goSibling(delta)
  }

  FilePreviewPane {
    id: pane
    anchors.fill: parent
    anchors.margins: 12
    filePath: root.filePath
    fileTitle: root.fileTitle
    cacheName: "file-preview.json"
    compactChrome: false
    interactiveDirs: true
    siblingPaths: root.siblingPaths
    siblingIndex: root.siblingIndex

    onEntryActivated: (path, title) => {
      Ranking.bump("file-dir-drill")
      root.filePath = path
      root.fileTitle = title
      // Rebuild siblings from parent dir listing when possible
      var sibs = []
      for (var i = 0; i < pane.dirEntries.length; i++)
        sibs.push(pane.dirEntries[i].path)
      if (sibs.length) {
        root.siblingPaths = sibs
        root.siblingIndex = sibs.indexOf(path)
      }
      pane.filePath = ""
      pane.filePath = path
      pane.fileTitle = title
    }

    onSiblingRequested: delta => root.goSibling(delta)
  }

  Component.onCompleted: {
    if (siblingPaths && siblingPaths.length && siblingIndex < 0) {
      for (var i = 0; i < siblingPaths.length; i++) {
        if (siblingPaths[i] === filePath) {
          siblingIndex = i
          break
        }
      }
    }
  }
}
