import QtQuick
import Quickshell
import Quickshell.Io
import "../services"
import "../components"

Item {
  id: root

  property var navStack: null
  property string filePath: ""
  property string fileTitle: ""
  property bool isLoading: true
  property string kind: ""
  property string mime: ""
  property string sizeLabel: ""
  property string modified: ""
  property string subtitle: ""
  property string previewText: ""
  property string imageSource: ""
  property var dirEntries: []
  property var opener: ({})
  property string errorText: ""

  signal requestActionPalette(var actions)
  signal requestDismiss()
  signal requestPushViewWithProps(string title, var component, var props)

  readonly property var selectedItem: ({
    primaryActionTitle: root.primaryLabel(),
    category: "File",
    actions: root.buildActions()
  })

  // Cache file is the source of truth (StdioCollector drops large stdout).
  FileView {
    id: previewCacheFile
    path: Paths.cacheFile("file-preview.json")
    blockLoading: true
    printErrors: false
  }

  property Process previewLoader: Process {
    property string pendingPath: ""
    command: ["python3", Paths.py("file_preview.py"), pendingPath]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => root.handlePreviewMeta(text)
    }
  }

  Timer {
    id: startTimer
    interval: 1
    repeat: false
    onTriggered: {
      if (!previewLoader.pendingPath.length)
        return
      // Explicit argv (ScriptResultView pattern) so Quickshell does not keep a stale empty path.
      previewLoader.command = ["python3", Paths.py("file_preview.py"), previewLoader.pendingPath]
      previewLoader.running = true
    }
  }

  function primaryLabel() {
    if (kind === "dir")
      return "Open Folder"
    if (opener && opener.title)
      return opener.title
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
        if (kind === "dir")
          Exec.openPath(root.filePath)
        else
          Exec.revealPath(root.filePath)
        root.requestDismiss()
      }
    })
    if (kind !== "dir") {
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
    var argv = (root.opener && root.opener.argv) ? root.opener.argv : null
    if (argv && argv.length)
      Exec.detached(argv)
    else
      Exec.openPath(root.filePath)
    Hud.success("Opening " + (root.fileTitle || root.filePath))
  }

  function loadPreview() {
    if (!filePath || !filePath.length) {
      errorText = "No path"
      isLoading = false
      return
    }
    isLoading = true
    errorText = ""
    previewText = ""
    imageSource = ""
    dirEntries = []
    kind = ""
    previewLoader.running = false
    previewLoader.pendingPath = filePath
    console.log("[Omnicast] file preview start:", filePath)
    startTimer.restart()
  }

  function applyPayload(data) {
    if (!data || !data.ok) {
      errorText = (data && data.error) ? data.error : "Preview failed"
      return
    }
    kind = data.kind || "binary"
    mime = data.mime || ""
    sizeLabel = data.size_label || ""
    modified = data.modified || ""
    subtitle = data.subtitle || data.path || filePath
    previewText = data.text || ""
    imageSource = data.image || ""
    dirEntries = data.entries || []
    opener = data.opener || {}
    if (!fileTitle || !fileTitle.length)
      fileTitle = data.name || filePath
  }

  function handlePreviewMeta(raw) {
    isLoading = false
    var meta = {}
    try {
      meta = JSON.parse((raw || "").trim() || "{}")
    } catch (e0) {
      console.error("[Omnicast] file preview meta parse failed:", e0, raw)
    }
    console.log("[Omnicast] file preview meta:", meta.ok, meta.kind, meta.path || "")

    // Prefer cache file (full payload). Fall back to inline meta only for errors.
    var cached = ""
    try {
      previewCacheFile.path = ""
      previewCacheFile.path = Paths.cacheFile("file-preview.json")
      cached = previewCacheFile.text() || ""
    } catch (e1) {
      console.error("[Omnicast] file preview cache read failed:", e1)
    }

    try {
      if (cached.length) {
        var data = JSON.parse(cached)
        var cachePath = (data && data.path) ? String(data.path) : ""
        var want = String(filePath || "")
        var metaPath = meta.path ? String(meta.path) : ""
        // Accept cache when it matches this request (resolved or as-passed)
        if (data && (cachePath === want || cachePath === metaPath || metaPath === want
                     || (meta.ok && metaPath.length && cachePath === metaPath))) {
          applyPayload(data)
          return
        }
      }
      if (meta && meta.ok === false) {
        errorText = meta.error || "Preview failed"
        return
      }
      errorText = "Preview failed (no cache)"
    } catch (e) {
      errorText = "Failed to parse preview"
      console.error("[Omnicast] file preview parse failed:", e, raw)
    }
  }

  function executeCurrent() {
    openExternal()
  }

  function openActionPalette() {
    root.requestActionPalette(buildActions())
  }

  Component.onCompleted: loadPreview()

  // ---- UI ----
  Flickable {
    id: scroll
    anchors.fill: parent
    anchors.margins: 14
    contentWidth: width
    contentHeight: body.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    Column {
      id: body
      width: parent.width
      spacing: 12

      Row {
        width: parent.width
        spacing: 10

        Text {
          width: parent.width - 80
          text: root.fileTitle || root.filePath
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontHeading
          font.weight: Font.DemiBold
          color: Theme.brightForeground
          elide: Text.ElideMiddle
          wrapMode: Text.NoWrap
        }

        Rectangle {
          visible: root.kind.length > 0
          anchors.verticalCenter: parent.verticalCenter
          height: 22
          radius: 4
          color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.18)
          border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.45)
          border.width: 1
          width: kindLabel.implicitWidth + 12

          Text {
            id: kindLabel
            anchors.centerIn: parent
            text: root.kind
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontCaption
            color: Theme.accent
          }
        }
      }

      Text {
        width: parent.width
        text: root.subtitle
        font.family: Theme.monoFontFamily
        font.pixelSize: Theme.fontBodySmall
        color: Theme.darkForeground
        wrapMode: Text.WrapAnywhere
      }

      Flow {
        width: parent.width
        spacing: 14

        Text {
          visible: root.sizeLabel.length > 0
          text: root.sizeLabel
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontCaption
          color: Theme.muted
        }
        Text {
          visible: root.modified.length > 0
          text: root.modified
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontCaption
          color: Theme.muted
        }
        Text {
          visible: root.mime.length > 0
          text: root.mime
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontCaption
          color: Theme.muted
        }
      }

      Text {
        visible: root.isLoading
        width: parent.width
        text: "Loading preview…"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody
        color: Theme.darkForeground
      }

      Text {
        visible: !root.isLoading && root.errorText.length > 0
        width: parent.width
        text: root.errorText
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody
        color: Theme.urgent
        wrapMode: Text.Wrap
      }

      // Image preview
      Rectangle {
        visible: !root.isLoading && root.imageSource.length > 0
        width: parent.width
        height: Math.min(320, Math.max(160, parent.width * 0.55))
        radius: Theme.itemRadius
        color: Theme.itemHoverBackground
        border.color: Theme.subtleBorder
        border.width: 1
        clip: true

        Image {
          anchors.fill: parent
          anchors.margins: 6
          source: root.imageSource
          fillMode: Image.PreserveAspectFit
          asynchronous: true
          smooth: true
        }
      }

      // Directory listing
      Column {
        visible: !root.isLoading && root.kind === "dir" && root.dirEntries.length > 0
        width: parent.width
        spacing: 4

        Text {
          text: "Contents"
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontBodySmall
          font.weight: Font.DemiBold
          color: Theme.brightForeground
        }

        Repeater {
          model: root.dirEntries
          delegate: Rectangle {
            width: body.width
            height: 28
            radius: 4
            color: "transparent"

            Row {
              anchors.fill: parent
              anchors.leftMargin: 4
              anchors.rightMargin: 4
              spacing: 8

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.is_dir ? "󰉋" : "󰈔"
                font.pixelSize: Theme.fontBody
                color: Theme.accent
              }
              Text {
                width: parent.width - 100
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.name
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
                color: Theme.foreground
                elide: Text.ElideMiddle
              }
              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.size_label || ""
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontCaption
                color: Theme.muted
              }
            }
          }
        }
      }

      // Text / extracted preview
      Rectangle {
        visible: !root.isLoading && root.previewText.length > 0 && root.imageSource.length === 0
        width: parent.width
        radius: Theme.itemRadius
        color: Theme.itemHoverBackground
        border.color: Theme.subtleBorder
        border.width: 1
        height: previewLabel.implicitHeight + 20

        Text {
          id: previewLabel
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.margins: 10
          text: root.previewText
          font.family: Theme.monoFontFamily
          font.pixelSize: Theme.fontBodySmall
          color: Theme.foreground
          wrapMode: Text.Wrap
        }
      }

      Text {
        visible: !root.isLoading && !root.errorText.length
                 && root.imageSource.length === 0 && root.previewText.length === 0
                 && !(root.kind === "dir" && root.dirEntries.length)
        width: parent.width
        text: "No inline preview. Press Enter to open externally."
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody
        color: Theme.darkForeground
        wrapMode: Text.Wrap
      }
    }
  }
}
