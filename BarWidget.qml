import QtQuick
import qs.Ui

BarWidget {
  id: root
  moduleName: "koustav.omnicast"

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
      // Right click opens terminal, Left click / middle click toggles Omnicast
      if (btn === Qt.RightButton) {
        root.bar.run("xdg-terminal-exec")
      } else {
        root.bar.run("omnicast toggle")
      }
    }
  }
}
