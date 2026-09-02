import QtQuick
import Quickshell
import Quickshell.Io
import "../services"
import "../components"

Item {
  id: root

  property var navStack: null
  property string scriptTitle: "Script Output"
  property string scriptPath: ""
  property var scriptArgs: []
  property string outputMarkdown: "Running script..."
  property bool isRunning: false

  signal requestActionPalette(var actions)
  signal requestDismiss()

  property Process scriptRunner: Process {
    command: ["python3", "/home/iamkxyz/Projects/omnicast/src/backend/script_runner.py", "exec", root.scriptPath]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => root.handleOutput(text)
    }
  }

  function runScript() {
    isRunning = true
    outputMarkdown = "### Executing Script...\n\n`" + root.scriptPath + "`"
    scriptRunner.running = true
  }

  function handleOutput(raw) {
    isRunning = false
    try {
      var res = JSON.parse(raw || "{}")
      if (res.status === "success") {
        root.outputMarkdown = res.stdout || "*Script completed with empty output.*"
      } else {
        root.outputMarkdown = "### ⚠️ Execution Error\n\n```text\n" + (res.stderr || res.error || "Unknown error") + "\n```"
      }
    } catch (e) {
      root.outputMarkdown = raw || "Script finished."
    }
  }

  DetailPane {
    anchors.fill: parent
    title: root.scriptTitle
    headerBadge: root.isRunning ? "Running" : "Output"
    markdownContent: root.outputMarkdown
    metadata: [
      { label: "Script Path", value: root.scriptPath.replace(/.*\/([^\/]+)$/, "$1") },
      { label: "Status", value: root.isRunning ? "Executing" : "Finished" }
    ]
  }

  function filter(query) {}
  function moveSelection(delta) {}
  function executeCurrent() {
    // Copy output
    Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "wl-copy \'' + root.outputMarkdown.replace(/'/g, "'\\''") + '\'"]; running: true }', root)
    root.requestDismiss()
  }

  function openActionPalette() {
    root.requestActionPalette([
      { title: "Copy Output to Clipboard", icon: "📋", shortcut: "↵", callback: function() { root.executeCurrent() } },
      { title: "Re-run Script", icon: "🔄", shortcut: "Ctrl+R", callback: function() { root.runScript() } }
    ])
  }

  Component.onCompleted: {
    runScript()
  }
}
