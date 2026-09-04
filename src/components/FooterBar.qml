import QtQuick
import "../services"

// Quiet text-only footer — no Raycast keycap chrome.
Item {
  id: root

  property string primaryActionText: "Open"
  property string subtitleText: "Omnicast"
  property bool showActionPaletteHint: true
  property bool canPop: false

  signal primaryActionClicked()
  signal actionPaletteClicked()

  height: Theme.footerHeight
  width: parent ? parent.width : Theme.cardWidth

  Text {
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    text: root.subtitleText
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontBodySmall
    color: Theme.foreground
    opacity: 0.40
  }

  Text {
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    text: "↵ " + root.primaryActionText + "   ⌃K Actions   Esc " + (root.canPop ? "Back" : "Close")
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontBodySmall
    color: Theme.foreground
    opacity: 0.40

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton
      onClicked: {
        // Click left third → primary; middle → actions (rough)
        var x = mouse.x / width
        if (x < 0.4) root.primaryActionClicked()
        else if (x < 0.7) root.actionPaletteClicked()
      }
    }
  }
}
