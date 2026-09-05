import QtQuick
import Quickshell
import Quickshell.Io
import "../services"

// Reusable file preview surface (side pane + full FilePreviewView).
Item {
  id: root

  property string filePath: ""
  property string fileTitle: ""
  property string cacheName: "file-preview.json"
  property bool compactChrome: false
  property bool interactiveDirs: true
  property var siblingPaths: []
  property int siblingIndex: -1

  property bool isLoading: false
  property string kind: ""
  property string mime: ""
  property string sizeLabel: ""
  property string modified: ""
  property string subtitle: ""
  property string previewText: ""
  property string previewHtml: ""
  property string textFormat: "plain"
  property string imageSource: ""
  property var dirEntries: []
  property var opener: ({})
  property string errorText: ""

  readonly property bool isProse: kind === "docx" || kind === "pdf" || kind === "office"
                                  || kind === "markdown" || kind === "text"
      readonly property int previewFontSize: isProse ? (compactChrome ? 15 : 16) : (compactChrome ? 12 : 14)
  readonly property real previewLineHeight: isProse ? 1.65 : 1.4
  readonly property string previewFontFamily: kind === "code"
                                              ? Theme.monoFontFamily
                                              : (isProse ? Theme.proseFontFamily : Theme.monoFontFamily)

  signal entryActivated(string path, string title)
  signal requestOpenExternal()
  signal siblingRequested(int delta)

  FileView {
    id: previewCacheFile
    path: Paths.cacheFile(root.cacheName)
    blockLoading: true
    printErrors: false
  }

  property Process previewLoader: Process {
    property string pendingPath: ""
    command: ["python3", Paths.py("file_preview.py"), pendingPath, "--cache", root.cacheName]
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
      previewLoader.command = [
        "python3", Paths.py("file_preview.py"),
        previewLoader.pendingPath, "--cache", root.cacheName
      ]
      previewLoader.running = true
    }
  }

  Timer {
    id: debounce
    interval: compactChrome ? 90 : 1
    repeat: false
    onTriggered: root.loadPreviewNow()
  }

  onFilePathChanged: {
    if (!filePath || !filePath.length) {
      clearPreview()
      return
    }
    isLoading = true
    errorText = ""
    debounce.restart()
  }

  function clearPreview() {
    isLoading = false
    errorText = ""
    kind = ""
    previewText = ""
    previewHtml = ""
    imageSource = ""
    dirEntries = []
    opener = ({})
    subtitle = ""
  }

  function loadPreviewNow() {
    if (!filePath || !filePath.length) {
      clearPreview()
      return
    }
    isLoading = true
    errorText = ""
    previewText = ""
    previewHtml = ""
    imageSource = ""
    dirEntries = []
    kind = ""
    textFormat = "plain"
    previewLoader.running = false
    previewLoader.pendingPath = filePath
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
    previewHtml = data.html || ""
    textFormat = data.text_format || "plain"
    imageSource = data.image || ""
    dirEntries = data.entries || []
    opener = data.opener || {}
    if (!fileTitle || !fileTitle.length)
      fileTitle = data.name || filePath
  }

  function handlePreviewMeta(raw) {
    // Ignore stale responses
    if (previewLoader.pendingPath !== filePath)
      return
    isLoading = false
    var meta = {}
    try {
      meta = JSON.parse((raw || "").trim() || "{}")
    } catch (e0) {
      console.error("[Omnicast] preview meta parse failed:", e0, raw)
    }

    var cached = ""
    try {
      previewCacheFile.path = ""
      previewCacheFile.path = Paths.cacheFile(root.cacheName)
      cached = previewCacheFile.text() || ""
    } catch (e1) {
      console.error("[Omnicast] preview cache read failed:", e1)
    }

    try {
      if (cached.length) {
        var data = JSON.parse(cached)
        var cachePath = (data && data.path) ? String(data.path) : ""
        var want = String(filePath || "")
        var metaPath = meta.path ? String(meta.path) : ""
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
      console.error("[Omnicast] preview parse failed:", e, raw)
    }
  }

  function goSibling(delta) {
    root.siblingRequested(delta)
  }

  Column {
    id: chrome
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    spacing: compactChrome ? 4 : 6

    Row {
      width: parent.width
      spacing: 8

      Text {
        width: parent.width
               - (kindBadge.visible ? kindBadge.width + 8 : 0)
               - (sibRow.visible ? sibRow.width + 8 : 0)
        text: root.fileTitle || root.filePath || "Preview"
        font.family: Theme.fontFamily
        font.pixelSize: compactChrome ? Theme.fontBody : Theme.fontHeading
        font.weight: Font.DemiBold
        color: Theme.brightForeground
        elide: Text.ElideMiddle
      }

      Row {
        id: sibRow
        visible: root.siblingPaths && root.siblingPaths.length > 1
        spacing: 4
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
          width: 22; height: 22; radius: 4
          color: Theme.itemHoverBackground
          border.color: Theme.subtleBorder; border.width: 1
          Text {
            anchors.centerIn: parent
            text: "‹"
            color: Theme.foreground
            font.pixelSize: 14
          }
          MouseArea {
            anchors.fill: parent
            onClicked: root.goSibling(-1)
          }
        }
        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: (Math.max(0, root.siblingIndex) + 1) + "/" + root.siblingPaths.length
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontCaption
          color: Theme.muted
        }
        Rectangle {
          width: 22; height: 22; radius: 4
          color: Theme.itemHoverBackground
          border.color: Theme.subtleBorder; border.width: 1
          Text {
            anchors.centerIn: parent
            text: "›"
            color: Theme.foreground
            font.pixelSize: 14
          }
          MouseArea {
            anchors.fill: parent
            onClicked: root.goSibling(1)
          }
        }
      }

      Rectangle {
        id: kindBadge
        visible: root.kind.length > 0
        anchors.verticalCenter: parent.verticalCenter
        height: 20
        radius: 4
        color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.18)
        border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.45)
        border.width: 1
        width: kindLabel.implicitWidth + 10

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
      visible: !compactChrome || root.subtitle.length > 0
      text: {
        var bits = []
        if (root.subtitle.length) bits.push(root.subtitle)
        if (root.sizeLabel.length) bits.push(root.sizeLabel)
        if (root.modified.length) bits.push(root.modified)
        return bits.join("  ·  ")
      }
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontCaption
      color: Theme.darkForeground
      elide: Text.ElideMiddle
    }
  }

  Item {
    id: readingPane
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: chrome.bottom
    anchors.bottom: parent.bottom
    anchors.topMargin: compactChrome ? 8 : 10

    Text {
      anchors.fill: parent
      visible: root.isLoading
      text: "Loading…"
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontBody
      color: Theme.darkForeground
    }

    Text {
      anchors.fill: parent
      visible: !root.isLoading && root.errorText.length > 0
      text: root.errorText
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontBody
      color: Theme.urgent
      wrapMode: Text.Wrap
    }

    // Image / PDF page
    Flickable {
      anchors.fill: parent
      visible: !root.isLoading && root.imageSource.length > 0
      contentWidth: width
      contentHeight: Math.max(height, imgCol.implicitHeight)
      clip: true
      boundsBehavior: Flickable.StopAtBounds

      Column {
        id: imgCol
        width: parent.width
        spacing: 10

        Rectangle {
          width: parent.width
          height: Math.min(root.height * 0.55, Math.max(180, parent.width * 0.7))
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

        Text {
          width: parent.width
          visible: root.previewText.length > 0
          text: root.previewText
          font.family: root.previewFontFamily
          font.pixelSize: root.previewFontSize - 1
          lineHeight: root.previewLineHeight
          lineHeightMode: Text.ProportionalHeight
          color: Theme.foreground
          wrapMode: Text.Wrap
        }
      }
    }

    // Directory listing
    Flickable {
      anchors.fill: parent
      visible: !root.isLoading && root.kind === "dir" && root.dirEntries.length > 0
      contentWidth: width
      contentHeight: dirCol.implicitHeight
      clip: true
      boundsBehavior: Flickable.StopAtBounds

      Column {
        id: dirCol
        width: parent.width
        spacing: 1

        Repeater {
          model: root.dirEntries
          delegate: Rectangle {
            width: dirCol.width
            height: 30
            radius: 4
            color: dirMa.containsMouse ? Theme.itemHoverBackground : "transparent"

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

            MouseArea {
              id: dirMa
              anchors.fill: parent
              hoverEnabled: true
              enabled: root.interactiveDirs
              onClicked: {
                var name = modelData.name || ""
                if (name.endsWith("/"))
                  name = name.slice(0, -1)
                root.entryActivated(modelData.path, name)
              }
            }
          }
        }
      }
    }

    // Text / markdown / code — document reading surface
    Flickable {
      id: textScroll
      anchors.fill: parent
      visible: !root.isLoading && root.previewText.length > 0 && root.imageSource.length === 0
               && root.kind !== "dir"
      contentWidth: width
      contentHeight: page.y + page.height + 8
      clip: true
      boundsBehavior: Flickable.StopAtBounds

      Rectangle {
        id: page
        x: 0
        y: 0
        width: textScroll.width
        height: Math.max(textScroll.height, previewBody.implicitHeight + pagePad * 2)
        radius: Theme.itemRadius
        color: Theme.itemHoverBackground
        border.color: Theme.subtleBorder
        border.width: 1

        readonly property int pagePad: root.isProse ? 18 : 14
        readonly property int proseMax: 560

        Text {
          id: previewBody
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.topMargin: page.pagePad
          anchors.leftMargin: page.pagePad
          width: root.isProse
                 ? Math.min(page.proseMax, parent.width - page.pagePad * 2)
                 : (parent.width - page.pagePad * 2)
          text: {
            if (root.textFormat === "html" && root.previewHtml.length)
              return root.previewHtml
            return root.previewText
          }
          textFormat: {
            if (root.textFormat === "html" && root.previewHtml.length)
              return Text.RichText
            if (root.textFormat === "markdown")
              return Text.MarkdownText
            return Text.PlainText
          }
          font.family: root.previewFontFamily
          font.pixelSize: root.previewFontSize
          lineHeight: root.previewLineHeight
          lineHeightMode: Text.ProportionalHeight
          color: Theme.brightForeground
          wrapMode: Text.Wrap
        }
      }
    }

    Text {
      anchors.fill: parent
      visible: !root.isLoading && !root.errorText.length
               && root.imageSource.length === 0 && root.previewText.length === 0
               && !(root.kind === "dir" && root.dirEntries.length)
               && root.filePath.length > 0
      text: "No inline preview"
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontBody
      color: Theme.darkForeground
    }

    Text {
      anchors.fill: parent
      visible: !root.filePath || !root.filePath.length
      text: "Select a file to preview"
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontBody
      color: Theme.darkForeground
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
    }
  }
}
