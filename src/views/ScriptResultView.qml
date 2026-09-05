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
  property string lastError: ""

  signal requestActionPalette(var actions)
  signal requestDismiss()

  readonly property var selectedItem: ({
    primaryActionTitle: "Copy Output",
    category: "Script"
  })

  property Process scriptRunner: Process {
    command: root._buildCommand()
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => root.handleOutput(text)
    }
  }

  function _buildCommand() {
    var cmd = ["python3", Paths.py("script_runner.py"), "exec", root.scriptPath]
    if (root.scriptArgs && root.scriptArgs.length) {
      for (var i = 0; i < root.scriptArgs.length; i++)
        cmd.push(String(root.scriptArgs[i]))
    }
    return cmd
  }

  function runScript() {
    isRunning = true
    lastError = ""
    outputMarkdown = "### Executing Script...\n\n`" + root.scriptPath + "`"
    scriptRunner.command = _buildCommand()
    scriptRunner.running = true
  }

  function handleOutput(raw) {
    isRunning = false
    try {
      var res = JSON.parse(raw || "{}")
      if (res.status === "success") {
        root.outputMarkdown = res.stdout || "*Script completed with empty output.*"
        Hud.success("Script finished")
      } else {
        root.lastError = res.stderr || res.error || "Unknown error"
        root.outputMarkdown = "### ⚠️ Execution Error\n\n```text\n" + root.lastError + "\n```"
        Hud.error("Script failed")
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
      { label: "Status", value: root.isRunning ? "Executing" : "Finished" },
      { label: "Args", value: (root.scriptArgs || []).join(" ") || ":" }
    ]
  }

  function filter(query) {}
  function moveSelection(delta) {}
  function executeCurrent() {
    Exec.copyText(root.outputMarkdown)
    Hud.success("Copied output")
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
