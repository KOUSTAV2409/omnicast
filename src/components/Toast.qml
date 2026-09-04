import QtQuick
import "../services"

// In-window toast (errors / async)
Rectangle {
  id: root
  property string message: ""
  property bool active: false
  property string detail: ""

  signal copyRequested()
  signal dismissRequested()

  anchors.horizontalCenter: parent.horizontalCenter
  anchors.top: parent.top
  anchors.topMargin: 58
  z: 200
  visible: opacity > 0
  opacity: active ? 1 : 0
  height: 40
  radius: 8
  width: Math.min(parent.width - 24, toastRow.implicitWidth + 20)
  color: Qt.rgba(0.15, 0.08, 0.08, 0.95)
  border.color: Qt.rgba(0.9, 0.35, 0.3, 0.7)
  border.width: 1

  Behavior on opacity {
    NumberAnimation { duration: 140 }
  }

  Row {
    id: toastRow
    anchors.centerIn: parent
    spacing: 10

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.message
      font.family: Theme.fontFamily
      font.pixelSize: 12
      color: Theme.brightForeground
    }

    Text {
      visible: root.detail.length > 0
      anchors.verticalCenter: parent.verticalCenter
      text: "Copy"
      font.family: Theme.fontFamily
      font.pixelSize: 12
      font.weight: Font.Bold
      color: Theme.accent
      MouseArea {
        anchors.fill: parent
        anchors.margins: -6
        onClicked: root.copyRequested()
      }
    }
  }

  function show(msg, detailText) {
    message = msg || "Error"
    detail = detailText || ""
    active = true
    hideTimer.restart()
  }

  function hide() {
    active = false
  }

  Timer {
    id: hideTimer
    interval: 4000
    onTriggered: root.hide()
  }
}
