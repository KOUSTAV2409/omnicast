import QtQuick
import "../services"

Rectangle {
  id: root

  property alias text: input.text
  property alias placeholderText: placeholder.text
  property alias textInput: input
  property string breadcrumbText: ""
  property bool busy: false

  signal textChangedByUser(string newText)
  signal clearRequested()
  signal escapePressed()
  signal actionPaletteRequested()
  signal submitPressed()
  signal moveDownRequested()
  signal moveUpRequested()

  height: 54
  color: "transparent"

  // Bottom Border Line
  Rectangle {
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    height: 1
    color: Theme.border
  }

  // 1. Search Leading Icon
  Text {
    id: leadingIcon
    anchors.left: parent.left
    anchors.leftMargin: 16
    anchors.verticalCenter: parent.verticalCenter
    text: "" // Nerd font search icon
    font.family: Theme.fontFamily
    font.pixelSize: 16
    color: input.text.length > 0 ? Theme.accent : Theme.muted
  }

  // 2. Breadcrumb Badge (if active in sub-view)
  Rectangle {
    id: breadcrumbBadge
    visible: root.breadcrumbText.length > 0
    anchors.left: leadingIcon.right
    anchors.leftMargin: 10
    anchors.verticalCenter: parent.verticalCenter
    height: 24
    radius: 4
    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
    border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.35)
    border.width: 1
    width: breadcrumbLabel.implicitWidth + 16

    Text {
      id: breadcrumbLabel
      anchors.centerIn: parent
      text: root.breadcrumbText
      font.family: Theme.fontFamily
      font.pixelSize: 12
      font.weight: Font.Medium
      color: Theme.accent
    }
  }

  // 3. Search Input Area
  Item {
    id: inputContainer
    anchors.left: breadcrumbBadge.visible ? breadcrumbBadge.right : leadingIcon.right
    anchors.leftMargin: 12
    anchors.right: clearBtn.visible ? clearBtn.left : parent.right
    anchors.rightMargin: 12
    anchors.top: parent.top
    anchors.bottom: parent.bottom

    Text {
      id: placeholder
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      text: "Search for apps, commands, files..."
      font.family: Theme.fontFamily
      font.pixelSize: 15
      color: Theme.muted
      visible: input.text.length === 0
    }

    TextInput {
      id: input
      anchors.fill: parent
      verticalAlignment: TextInput.AlignVCenter
      font.family: Theme.fontFamily
      font.pixelSize: 15
      color: Theme.brightForeground
      selectionColor: Theme.accent
      selectedTextColor: Theme.darkerBackground
      clip: true
      focus: true

      onTextChanged: {
        root.textChangedByUser(text)
      }

      Keys.onPressed: event => {
        if (event.key === Qt.Key_Down || (event.key === Qt.Key_N && event.modifiers & Qt.ControlModifier)) {
          root.moveDownRequested()
          event.accepted = true
        } else if (event.key === Qt.Key_Up || (event.key === Qt.Key_P && event.modifiers & Qt.ControlModifier)) {
          root.moveUpRequested()
          event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          root.submitPressed()
          event.accepted = true
        } else if (event.key === Qt.Key_Escape) {
          root.escapePressed()
          event.accepted = true
        } else if (event.key === Qt.Key_Tab || (event.key === Qt.Key_K && event.modifiers & Qt.ControlModifier)) {
          root.actionPaletteRequested()
          event.accepted = true
        }
      }
    }
  }

  // 4. Clear Button
  Rectangle {
    id: clearBtn
    visible: input.text.length > 0
    anchors.right: parent.right
    anchors.rightMargin: 16
    anchors.verticalCenter: parent.verticalCenter
    width: 20
    height: 20
    radius: 10
    color: clearMouse.containsMouse ? Theme.itemHoverBackground : "transparent"

    Text {
      anchors.centerIn: parent
      text: "✕"
      font.pixelSize: 11
      color: Theme.muted
    }

    MouseArea {
      id: clearMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: {
        input.text = ""
        root.clearRequested()
        input.forceActiveFocus()
      }
    }
  }

  function clear() {
    input.text = ""
  }

  function setFocus() {
    input.forceActiveFocus()
  }
}
