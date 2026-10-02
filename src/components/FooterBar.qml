import QtQuick
import "../services"

// Quiet text-only footer: no Raycast keycap chrome.
Item {
  id: root

  property string primaryActionText: "Open"
  property string subtitleText: "Omnicast"
  property string hintText: "Enter · Ctrl+K · Esc"
  property bool showActionPaletteHint: true
  property bool canPop: false

  signal primaryActionClicked()
  signal actionPaletteClicked()

  height: Theme.footerHeight
  width: parent ? parent.width : Theme.cardWidth

  Text {
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    width: Math.min(implicitWidth, parent.width * 0.42)
    text: root.subtitleText
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontBodySmall
    color: Theme.foreground
    opacity: 0.45
    elide: Text.ElideRight
  }

  Text {
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    text: {
      var close = root.canPop ? "Esc Back" : "Esc"
      var primary = root.primaryActionText.length ? ("Enter " + root.primaryActionText) : "Enter"
      var base = primary + " · Ctrl+K · " + close
      // Append Files scope context — never replace Enter/Ctrl+K
      if (root.hintText.length && root.hintText.indexOf("Files") === 0)
        return base.replace(" · " + close, "") + " · " + root.hintText + " · " + close
      if (root.hintText.length && root.hintText !== "Enter · Ctrl+K · Esc")
        return root.hintText
      return base
    }
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontBodySmall
    color: Theme.foreground
    opacity: 0.48

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton
      onClicked: {
        var x = mouse.x / width
        if (x < 0.35) root.primaryActionClicked()
        else if (x < 0.55) root.actionPaletteClicked()
      }
    }
  }
}
