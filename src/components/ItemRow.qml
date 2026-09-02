import QtQuick
import "../services"

Rectangle {
  id: root

  property string title: ""
  property string subtitle: ""
  property string iconText: ""
  property string badgeText: ""
  property string shortcutHint: ""
  property bool isSelected: false
  property bool isSectionHeader: false

  signal clicked()

  height: isSectionHeader ? 28 : 44
  color: isSectionHeader ? "transparent" : (isSelected ? Theme.itemSelectedBackground : "transparent")
  radius: Theme.itemRadius

  // Left accent pill when selected
  Rectangle {
    id: accentBar
    visible: root.isSelected && !root.isSectionHeader
    anchors.left: parent.left
    anchors.leftMargin: 4
    anchors.verticalCenter: parent.verticalCenter
    width: 3
    height: parent.height - 16
    radius: 1.5
    color: Theme.accent
  }

  // Section Header Layout
  Item {
    visible: root.isSectionHeader
    anchors.fill: parent
    anchors.leftMargin: 16
    anchors.rightMargin: 16

    Text {
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      text: root.title.toUpperCase()
      font.family: Theme.fontFamily
      font.pixelSize: 11
      font.weight: Font.Bold
      font.letterSpacing: 1.2
      color: Theme.muted
    }
  }

  // Standard Item Row Layout
  Row {
    visible: !root.isSectionHeader
    anchors.fill: parent
    anchors.leftMargin: root.isSelected ? 16 : 14
    anchors.rightMargin: 14
    spacing: 12

    // Leading Icon Box
    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      width: 28
      height: 28
      radius: 6
      color: root.isSelected ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Theme.itemHoverBackground

      Text {
        anchors.centerIn: parent
        text: root.iconText
        font.family: Theme.fontFamily
        font.pixelSize: 14
        color: root.isSelected ? Theme.accent : Theme.lightForeground
      }
    }

    // Title + Subtitle
    Column {
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width - 28 - (rightBadges.implicitWidth > 0 ? rightBadges.implicitWidth + 12 : 0) - 24
      spacing: 2

      Text {
        text: root.title
        font.family: Theme.fontFamily
        font.pixelSize: 14
        font.weight: root.isSelected ? Font.DemiBold : Font.Normal
        color: root.isSelected ? Theme.brightForeground : Theme.lightForeground
        elide: Text.ElideRight
        width: parent.width
      }

      Text {
        visible: root.subtitle.length > 0
        text: root.subtitle
        font.family: Theme.fontFamily
        font.pixelSize: 11
        color: root.isSelected ? Theme.lightForeground : Theme.muted
        elide: Text.ElideRight
        width: parent.width
      }
    }

    // Trailing Accessories / Badges
    Row {
      id: rightBadges
      anchors.verticalCenter: parent.verticalCenter
      spacing: 6

      // Category / Status Badge
      Rectangle {
        visible: root.badgeText.length > 0
        anchors.verticalCenter: parent.verticalCenter
        height: 20
        radius: 4
        color: root.isSelected ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2) : Theme.itemHoverBackground
        border.color: root.isSelected ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4) : Theme.border
        border.width: 1
        width: badgeLabel.implicitWidth + 12

        Text {
          id: badgeLabel
          anchors.centerIn: parent
          text: root.badgeText
          font.family: Theme.fontFamily
          font.pixelSize: 10
          font.weight: Font.Medium
          color: root.isSelected ? Theme.accent : Theme.muted
        }
      }

      // Hotkey hint badge
      Rectangle {
        visible: root.shortcutHint.length > 0
        anchors.verticalCenter: parent.verticalCenter
        height: 20
        radius: 4
        color: Theme.itemHoverBackground
        border.color: Theme.border
        border.width: 1
        width: shortcutLabel.implicitWidth + 10

        Text {
          id: shortcutLabel
          anchors.centerIn: parent
          text: root.shortcutHint
          font.family: Theme.monoFontFamily
          font.pixelSize: 10
          color: Theme.muted
        }
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      if (!root.isSectionHeader) root.clicked()
    }
  }
}
