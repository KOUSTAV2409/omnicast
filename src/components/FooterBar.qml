import QtQuick
import "../services"

Rectangle {
  id: root

  property string primaryActionText: "Open"
  property string subtitleText: "Omnicast"
  property bool showActionPaletteHint: true
  property bool canPop: false

  signal primaryActionClicked()
  signal actionPaletteClicked()

  height: 38
  color: Qt.rgba(Theme.darkBackground.r, Theme.darkBackground.g, Theme.darkBackground.b, 0.92)

  Rectangle {
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: 1
    color: Theme.border
  }

  // Left Subtitle / Category
  Row {
    anchors.left: parent.left
    anchors.leftMargin: 16
    anchors.verticalCenter: parent.verticalCenter
    spacing: 8

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.subtitleText
      font.family: Theme.fontFamily
      font.pixelSize: 12
      font.weight: Font.Medium
      color: Theme.muted
    }
  }

  // Right Action Pills
  Row {
    anchors.right: parent.right
    anchors.rightMargin: 16
    anchors.verticalCenter: parent.verticalCenter
    spacing: 12

    // Primary Action (e.g. ↵ Open)
    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      height: 24
      radius: 4
      color: primaryMouse.containsMouse ? Theme.itemHoverBackground : "transparent"
      width: primaryRow.implicitWidth + 12

      Row {
        id: primaryRow
        anchors.centerIn: parent
        spacing: 6

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 18
          height: 16
          radius: 3
          color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25)
          border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.6)
          border.width: 1

          Text {
            anchors.centerIn: parent
            text: "↵"
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.weight: Font.Bold
            color: Theme.accent
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: root.primaryActionText
          font.family: Theme.fontFamily
          font.pixelSize: 12
          font.weight: Font.Medium
          color: Theme.lightForeground
        }
      }

      MouseArea {
        id: primaryMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.primaryActionClicked()
      }
    }

    // Action Palette (Ctrl+K)
    Rectangle {
      visible: root.showActionPaletteHint
      anchors.verticalCenter: parent.verticalCenter
      height: 24
      radius: 4
      color: actionMouse.containsMouse ? Theme.itemHoverBackground : "transparent"
      width: actionRow.implicitWidth + 12

      Row {
        id: actionRow
        anchors.centerIn: parent
        spacing: 6

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 24
          height: 16
          radius: 3
          color: Theme.itemHoverBackground
          border.color: Theme.border
          border.width: 1

          Text {
            anchors.centerIn: parent
            text: "⌃K"
            font.family: Theme.monoFontFamily
            font.pixelSize: 10
            font.weight: Font.Bold
            color: Theme.muted
          }
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: "Actions"
          font.family: Theme.fontFamily
          font.pixelSize: 12
          color: Theme.muted
        }
      }

      MouseArea {
        id: actionMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.actionPaletteClicked()
      }
    }

    // Back / Close (Esc)
    Row {
      anchors.verticalCenter: parent.verticalCenter
      spacing: 5

      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 26
        height: 16
        radius: 3
        color: Theme.itemHoverBackground
        border.color: Theme.border
        border.width: 1

        Text {
          anchors.centerIn: parent
          text: "Esc"
          font.family: Theme.monoFontFamily
          font.pixelSize: 9
          font.weight: Font.Bold
          color: Theme.muted
        }
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.canPop ? "Back" : "Close"
        font.family: Theme.fontFamily
        font.pixelSize: 12
        color: Theme.muted
      }
    }
  }
}
