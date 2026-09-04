import QtQuick
import "../services"

// Omarchy-menu-style search header: large heading text, no icon chrome.
Item {
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
  signal categoryCycleRequested()

  height: Theme.headerHeight
  width: parent ? parent.width : Theme.cardWidth

  Text {
    id: breadcrumb
    visible: root.breadcrumbText.length > 0
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    text: root.breadcrumbText + " · "
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontHeading
    font.weight: Font.Medium
    color: Theme.muted
  }

  Text {
    id: placeholder
    anchors.left: breadcrumb.visible ? breadcrumb.right : parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    text: "Search…"
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontHeading
    font.weight: Font.Medium
    color: Theme.foreground
    opacity: 0.58
    visible: input.text.length === 0 && !root.busy
    elide: Text.ElideRight
  }

  Text {
    anchors.left: breadcrumb.visible ? breadcrumb.right : parent.left
    anchors.verticalCenter: parent.verticalCenter
    visible: root.busy && input.text.length === 0
    text: "Loading…"
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontHeading
    font.weight: Font.Medium
    color: Theme.foreground
    opacity: 0.45
  }

  TextInput {
    id: input
    anchors.left: breadcrumb.visible ? breadcrumb.right : parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    height: parent.height
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontHeading
    font.weight: Font.Medium
    color: Theme.foreground
    selectionColor: Theme.accent
    selectedTextColor: Theme.darkerBackground
    clip: true
    focus: true
    cursorVisible: activeFocus

    onTextChanged: root.textChangedByUser(text)

    Keys.onPressed: event => {
      if (event.key === Qt.Key_Down || (event.key === Qt.Key_N && event.modifiers & Qt.ControlModifier)) {
        root.moveDownRequested(); event.accepted = true
      } else if (event.key === Qt.Key_Up || (event.key === Qt.Key_P && event.modifiers === Qt.ControlModifier)) {
        root.moveUpRequested(); event.accepted = true
      } else if (event.key === Qt.Key_P && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier)) {
        root.categoryCycleRequested(); event.accepted = true
      } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
        root.submitPressed(); event.accepted = true
      } else if (event.key === Qt.Key_Escape) {
        root.escapePressed(); event.accepted = true
      } else if (event.key === Qt.Key_Tab || (event.key === Qt.Key_K && event.modifiers & Qt.ControlModifier)) {
        root.actionPaletteRequested(); event.accepted = true
      }
    }
  }

  function clear() { input.text = "" }
  function setFocus() { input.forceActiveFocus() }
}
