import QtQuick
import "../services"

Item {
  id: root

  property string title: "No Results Found"
  property string subtitle: "Try searching for a different keyword or app"
  property string iconText: ""

  anchors.centerIn: parent
  width: 320
  height: 160

  Column {
    anchors.centerIn: parent
    spacing: 12

    // Icon Circle
    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      width: 44
      height: 44
      radius: 22
      color: Theme.itemHoverBackground
      border.color: Theme.border
      border.width: 1

      Text {
        anchors.centerIn: parent
        text: root.iconText
        font.family: Theme.fontFamily
        font.pixelSize: 18
        color: Theme.muted
      }
    }

    // Title & Subtitle
    Column {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 4

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.title
        font.family: Theme.fontFamily
        font.pixelSize: 14
        font.weight: Font.DemiBold
        color: Theme.lightForeground
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.subtitle
        font.family: Theme.fontFamily
        font.pixelSize: 12
        color: Theme.muted
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        width: root.width
      }
    }
  }
}
