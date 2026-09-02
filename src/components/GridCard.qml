import QtQuick
import "../services"

Rectangle {
  id: root

  property string title: ""
  property string subtitle: ""
  property string iconText: ""
  property string previewColor: ""
  property string imageSource: ""
  property string badgeText: ""
  property bool isSelected: false

  signal clicked()

  height: 120
  radius: Theme.itemRadius
  color: isSelected ? Theme.itemSelectedBackground : (cardMouse.containsMouse ? Theme.itemHoverBackground : Theme.cardBackground)
  border.color: isSelected ? Theme.accent : (cardMouse.containsMouse ? Theme.border : Theme.subtleBorder)
  border.width: isSelected ? 1.5 : 1

  Column {
    anchors.fill: parent
    anchors.margins: 8
    spacing: 6

    // Top Visual Area (Color Swatch, Image, or Large Icon)
    Rectangle {
      width: parent.width
      height: 64
      radius: 6
      color: root.previewColor.length > 0 ? root.previewColor : Theme.itemHoverBackground
      border.color: Theme.subtleBorder
      border.width: 1
      clip: true

      Image {
        visible: root.imageSource.length > 0
        anchors.fill: parent
        source: root.imageSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
      }

      Text {
        visible: root.imageSource.length === 0 && root.previewColor.length === 0
        anchors.centerIn: parent
        text: root.iconText
        font.pixelSize: 24
        color: root.isSelected ? Theme.accent : Theme.lightForeground
      }

      // Small Badge in top right corner of preview
      Rectangle {
        visible: root.badgeText.length > 0
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 4
        height: 16
        radius: 3
        color: Qt.rgba(0, 0, 0, 0.6)
        width: badgeTextLabel.implicitWidth + 8

        Text {
          id: badgeTextLabel
          anchors.centerIn: parent
          text: root.badgeText
          font.family: Theme.fontFamily
          font.pixelSize: 9
          font.weight: Font.Bold
          color: Theme.brightForeground
        }
      }
    }

    // Bottom Title & Subtitle
    Column {
      width: parent.width
      spacing: 1

      Text {
        width: parent.width
        text: root.title
        font.family: Theme.fontFamily
        font.pixelSize: 13
        font.weight: root.isSelected ? Font.DemiBold : Font.Medium
        color: root.isSelected ? Theme.brightForeground : Theme.lightForeground
        elide: Text.ElideRight
      }

      Text {
        visible: root.subtitle.length > 0
        width: parent.width
        text: root.subtitle
        font.family: Theme.fontFamily
        font.pixelSize: 11
        color: Theme.muted
        elide: Text.ElideRight
      }
    }
  }

  MouseArea {
    id: cardMouse
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
