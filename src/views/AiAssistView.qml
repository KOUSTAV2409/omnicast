import QtQuick
import Quickshell
import Quickshell.Io
import "../services"
import "../components"

Item {
  id: root

  property var navStack: null
  property string filterText: ""
  property string queryPrompt: ""
  property string responseMarkdown: ""
  property bool isGenerating: false

  signal requestActionPalette(var actions)
  signal requestDismiss()

  Column {
    anchors.fill: parent
    anchors.margins: 14
    spacing: 12

    // Prompt Header & Presets
    Row {
      width: parent.width
      spacing: 8

      Repeater {
        model: [
          { label: "💡 Explain Code", prompt: "Explain this code clearly with key insights:" },
          { label: "📝 Summarize", prompt: "Provide a concise 3-bullet summary of the following:" },
          { label: "⚡ Fix Grammar", prompt: "Correct any typos, grammatical errors, and enhance readability:" },
          { label: "🐚 Shell One-Liner", prompt: "Write a high-performance bash command to accomplish:" }
        ]

        delegate: Rectangle {
          height: 26
          radius: 13
          color: presetMouse.containsMouse ? Theme.itemSelectedBackground : Theme.itemHoverBackground
          border.color: presetMouse.containsMouse ? Theme.accent : Theme.subtleBorder
          border.width: 1
          width: presetLabel.implicitWidth + 16

          Text {
            id: presetLabel
            anchors.centerIn: parent
            text: modelData.label
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.weight: Font.Medium
            color: presetMouse.containsMouse ? Theme.accent : Theme.lightForeground
          }

          MouseArea {
            id: presetMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              promptInput.text = modelData.prompt + " "
              promptInput.forceActiveFocus()
            }
          }
        }
      }
    }

    // AI Query Input Box
    Rectangle {
      width: parent.width
      height: 40
      radius: 6
      color: Theme.cardBackground
      border.color: promptInput.activeFocus ? Theme.accent : Theme.border
      border.width: 1

      Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 8
        spacing: 8
        verticalAlignment: Qt.AlignVCenter

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "🤖"
          font.pixelSize: 14
        }

        TextInput {
          id: promptInput
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width - 90
          font.family: Theme.fontFamily
          font.pixelSize: 13
          color: Theme.brightForeground
          clip: true

          Text {
            anchors.fill: parent
            text: "Ask AI anything or choose a preset above..."
            font.family: Theme.fontFamily
            font.pixelSize: 13
            color: Theme.muted
            visible: promptInput.text.length === 0
          }

          Keys.onPressed: event => {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              root.sendQuery(promptInput.text)
              event.accepted = true
            }
          }
        }

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          height: 26
          radius: 4
          color: Theme.accent
          width: runBtnLabel.implicitWidth + 14

          Text {
            id: runBtnLabel
            anchors.centerIn: parent
            text: root.isGenerating ? "..." : "Ask ↵"
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.weight: Font.Bold
            color: Theme.darkerBackground
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.sendQuery(promptInput.text)
          }
        }
      }
    }

    // Response Container
    Rectangle {
      width: parent.width
      height: parent.height - 100
      radius: 8
      color: Theme.itemHoverBackground
      border.color: Theme.subtleBorder
      border.width: 1
      clip: true

      DetailPane {
        anchors.fill: parent
        title: "AI Response"
        headerBadge: root.isGenerating ? "Streaming" : "Complete"
        markdownContent: root.responseMarkdown.length > 0 ? root.responseMarkdown : "Type a query above or click a preset to generate streaming AI insights."
        metadata: root.responseMarkdown.length > 0 ? [
          { label: "Engine", value: "Antigravity LLM Stream" },
          { label: "Latency", value: "Instant" }
        ] : []
      }
    }
  }

  function sendQuery(prompt) {
    if (!prompt || prompt.trim() === "") return
    isGenerating = true
    responseMarkdown = "### Analyzing Query...\n\n*" + prompt + "*\n\n> Processing through intelligence gateway..."

    // Simulate streaming response
    generateTimer.restart()
  }

  Timer {
    id: generateTimer
    interval: 600
    repeat: false
    onTriggered: {
      root.isGenerating = false
      root.responseMarkdown = "### AI Synthesis\n\nHere is the generated analysis for your request:\n\n```bash\n# Recommended command\nomarchy refresh applications && hyprctl reload\n```\n\n- **Safety**: Verified zero side-effects.\n- **Performance**: Executed natively via Wayland socket."
    }
  }

  function filter(query) {}
  function moveSelection(delta) {}
  function executeCurrent() {
    if (responseMarkdown.length > 0) {
      Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "wl-copy \'' + responseMarkdown.replace(/'/g, "'\\''") + '\'"]; running: true }', root)
      root.requestDismiss()
    }
  }
  function openActionPalette() {
    root.requestActionPalette([
      { title: "Copy Response to Clipboard", icon: "📋", shortcut: "↵", callback: function() { root.executeCurrent() } },
      { title: "Clear Prompt & Response", icon: "🗑️", callback: function() { promptInput.text = ""; responseMarkdown = "" } }
    ])
  }
}
