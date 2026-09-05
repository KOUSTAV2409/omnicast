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
  property bool hovered: false

  signal clicked()
  signal doubleClicked()

  height: isSectionHeader ? Theme.sectionHeight : Theme.rowHeight
  radius: Math.max(Theme.itemRadius, 4)
  color: {
    if (isSectionHeader)
      return "transparent"
    if (isSelected)
      return Theme.itemSelectedBackground
    if (hovered)
      return Theme.itemHoverBackground
    return "transparent"
  }
  border.width: 0

  Behavior on color { ColorAnimation { duration: 110; easing.type: Easing.OutCubic } }

  // Accent rail — makes selection feel intentional
  Rectangle {
    visible: !root.isSectionHeader && root.isSelected
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    width: 2
    height: parent.height - 10
    radius: 1
    color: Theme.accent
    opacity: 0.95
  }

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
    anchors.leftMargin: 10
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
      opacity: root.isSelected ? 1.0 : 0.85
      Behavior on color { ColorAnimation { duration: 110 } }
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
        Behavior on color { ColorAnimation { duration: 110 } }
      }

      Text {
        width: parent.width
        visible: root.subtitle.length > 0
        text: root.subtitle
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBodySmall
        color: Theme.foreground
        opacity: root.isSelected ? 0.55 : 0.42
        elide: Text.ElideRight
      }
    }

    Text {
      id: trail
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      text: root.shortcutHint.length ? root.shortcutHint : (root.badgeText === "Omnicast" ? "·" : (root.badgeText === "Content" ? "∋" : ""))
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontCaption
      color: root.badgeText === "Content" ? Theme.accent : Theme.foreground
      opacity: root.badgeText === "Content" ? 0.7 : 0.28
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: root.isSectionHeader ? Qt.ArrowCursor : Qt.PointingHandCursor
    onEntered: root.hovered = true
    onExited: root.hovered = false
    onClicked: { if (!root.isSectionHeader) root.clicked() }
    onDoubleClicked: { if (!root.isSectionHeader) root.doubleClicked() }
  }
}
