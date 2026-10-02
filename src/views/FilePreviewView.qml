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
          root.openExternal()
        }
      })
    }
    return acts
  }

  function openExternal() {
    if (pane.kind === "blocked" || (pane.opener && pane.opener.id === "none")) {
      Hud.error(pane.errorText || "Blocked: sensitive path")
      return
    }
    var p = String(root.filePath || "")
    var low = p.toLowerCase()
    // Match RootSearchView.openFileSmart: never xdg-open scripts/binaries
    if (/\.(sh|bash|zsh|fish|py|rb|pl|js|mjs|cjs|exe|bin|run|appimage)$/.test(low)) {
      Exec.copyText(p)
      Hud.error("Script/binary not launched — path copied")
      return
    }
    if (pane.opener && pane.opener.argv && pane.opener.argv.length) {
      var argvPath = ""
      var argv = pane.opener.argv
      for (var i = 0; i < argv.length; i++) {
        var a = String(argv[i] || "")
        if (a.indexOf("--view=") === 0)
          argvPath = a.substring(7)
        else if (a.indexOf("/") === 0 || a.indexOf("~") === 0)
          argvPath = a
      }
      if (argvPath.length && argvPath !== root.filePath) {
        Hud.error("Preview out of sync — reopen from search")
        return
      }
      var bin = String(argv[0] || "")
      if (bin !== "xdg-open" && bin.indexOf("onlyoffice") < 0) {
        Hud.error("Blocked: unexpected opener")
        return
      }
      Ranking.bump("file-open-external")
      root.requestDismiss()
      Exec.detached(argv)
      Hud.success("Opening " + (root.fileTitle || root.filePath))
      return
    }
    Ranking.bump("file-open-external")
    root.requestDismiss()
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
    // Only sibling-browse when we have a real position in the set
    if (siblingPaths && siblingPaths.length > 1 && siblingIndex >= 0)
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
