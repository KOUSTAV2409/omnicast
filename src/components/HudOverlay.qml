import QtQuick
import "../services"

// Floating HUD pill — lives outside the main card (full screen overlay layer)
Item {
  id: root
  anchors.fill: parent
  visible: Hud.visible
  z: 1000

  Rectangle {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 48
    height: 36
    radius: 18
    width: Math.min(parent.width - 40, hudLabel.implicitWidth + 28)
    color: Hud.kind === "error"
           ? Qt.rgba(0.75, 0.2, 0.2, 0.92)
           : Qt.rgba(Theme.darkBackground.r, Theme.darkBackground.g, Theme.darkBackground.b, 0.94)
    border.color: Theme.border
    border.width: 1
    opacity: Hud.visible ? 1 : 0

    Behavior on opacity {
      NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
    }

    Text {
      id: hudLabel
      anchors.centerIn: parent
      text: Hud.message
      font.family: Theme.fontFamily
      font.pixelSize: 13
      font.weight: Font.Medium
      color: Theme.brightForeground
    }
  }
}
