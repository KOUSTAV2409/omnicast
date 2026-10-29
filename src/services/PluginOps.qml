pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
  id: root

  signal finished(bool ok, string op, string pluginId, string message)

  readonly property bool busy: runner.running

  Process {
    id: runner
    property string payload: ""
    command: ["python3", Paths.py("plugin_catalog.py"), "op-json"]
    stdinEnabled: true
    running: false
    onStarted: {
      write(payload + "\n")
      payload = ""
    }
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => root._done(text)
    }
  }

  function run(op, pluginId) {
    if (runner.running) {
      Hud.info("A plugin action is already running")
      return
    }
    runner.payload = JSON.stringify({ op: String(op || ""), id: String(pluginId || "") })
    runner.running = true
  }

  function _done(raw) {
    var ok = false
    var op = ""
    var pluginId = ""
    var message = ""
    try {
      var data = JSON.parse((raw || "").trim() || "{}")
      ok = !!data.ok
      op = data.op || ""
      pluginId = data.id || ""
      message = data.message || data.error || ""
    } catch (e) {
      message = "Plugin action failed"
    }
    if (ok)
      Hud.success(message || "Done")
    else
      Hud.error(message || "Plugin action failed")
    finished(ok, op, pluginId, message)
  }
}
