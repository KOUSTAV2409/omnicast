import QtQuick
import qs.Ui

BarWidget {
  id: root
  moduleName: "koustav.omnicast"

  // Always invoke the launcher shipped with this plugin. Do not rely on PATH
  // (plugin-only installs never put omnicast on PATH unless the user ran install.sh).
  readonly property string omnicastBin: {
    var u = Qt.resolvedUrl("bin/omnicast").toString()
    // file:///path → /path
    if (u.indexOf("file://") === 0)
      u = u.substring(7)
    if (u.indexOf("localhost") === 0)
      u = u.substring(9)
    return u
  }

  function shellQuote(s) {
    return "'" + String(s || "").replace(/'/g, "'\\''") + "'"
  }

  function runOmnicast(args) {
    if (!root.bar) return
    var cmd = root.shellQuote(root.omnicastBin)
    if (args && String(args).length)
      cmd += " " + String(args)
    root.bar.run(cmd)
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\uf002"
    tooltipText: "Omnicast (Alt+Space)"
    horizontalMargin: 8.5
    onPressed: function(btn) {
      if (!root.bar) return
      // Right click opens terminal; left/middle toggles Omnicast
      if (btn === Qt.RightButton) {
        root.bar.run("xdg-terminal-exec")
      } else {
        root.runOmnicast("toggle")
      }
    }
  }
}
