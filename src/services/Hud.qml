pragma Singleton
import QtQuick

QtObject {
  id: root

  property string message: ""
  property string kind: "info" // info | success | error
  property bool visible: false

  signal shown(string message, string kind)

  property var _timer: Timer {
    interval: 1800
    repeat: false
    onTriggered: root.visible = false
  }

  function show(msg, k) {
    message = msg || ""
    kind = k || "success"
    visible = true
    shown(message, kind)
    _timer.restart()
  }

  function success(msg) { show(msg, "success") }
  function error(msg) { show(msg, "error") }
  function info(msg) { show(msg, "info") }
}
