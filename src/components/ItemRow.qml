import QtQuick
import "../services"

// Omarchy menu/clipboard row language: plain glyph + heading label + soft selection fill.
Rectangle {
  id: root

  property string title: ""
  property string subtitle: ""
  property string iconText: ""
  property string badgeText: ""
  property string shortcutHint: ""
  property bool isSelected: false
  property bool isSectionHeader: false

  signal clicked()
  signal doubleClicked()

  height: isSectionHeader ? Theme.sectionHeight : Theme.rowHeight
  radius: Theme.windowRadius
  color: (!isSectionHeader && isSelected) ? Theme.itemSelectedBackground : "transparent"
  border.width: 0

  Item {
    visible: root.isSectionHeader
    anchors.fill: parent
    anchors.leftMargin: 4
    anchors.rightMargin: 4

    Text {
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: root.title
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontCaption
      font.weight: Font.Medium
      font.letterSpacing: 0.8
      color: Theme.foreground
      opacity: 0.40
    }
  }

  Item {
    visible: !root.isSectionHeader
    anchors.fill: parent
    anchors.leftMargin: 8
    anchors.rightMargin: 10

    Text {
      id: iconGlyph
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      width: Theme.iconSlot
      horizontalAlignment: Text.AlignHCenter
      text: root.iconText
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontIcon
      color: root.isSelected ? Theme.itemSelectedText : Theme.foreground
    }

    Column {
      anchors.left: iconGlyph.right
      anchors.leftMargin: 6
      anchors.right: trail.left
      anchors.rightMargin: 8
      anchors.verticalCenter: parent.verticalCenter
      spacing: 3

      Text {
        width: parent.width
        text: root.title
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontHeading
        font.weight: Font.Medium
        color: root.isSelected ? Theme.itemSelectedText : Theme.foreground
        elide: Text.ElideRight
      }

      Text {
        width: parent.width
        visible: root.subtitle.length > 0
        text: root.subtitle
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBodySmall
        color: Theme.foreground
        opacity: 0.45
        elide: Text.ElideRight
      }
    }

    Text {
      id: trail
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      text: root.shortcutHint.length ? root.shortcutHint : (root.badgeText === "Omnicast" ? "·" : "")
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontCaption
      color: Theme.foreground
      opacity: 0.28
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: root.isSectionHeader ? Qt.ArrowCursor : Qt.PointingHandCursor
    onClicked: { if (!root.isSectionHeader) root.clicked() }
    onDoubleClicked: { if (!root.isSectionHeader) root.doubleClicked() }
  }
}
