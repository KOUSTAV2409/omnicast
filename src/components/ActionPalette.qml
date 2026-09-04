import QtQuick
import "../services"

Rectangle {
  id: root

  property bool active: false
  property var actions: [] // Array of { title: string, subtitle: string, icon: string, shortcut: string, callback: function }
  property var filteredActions: []
  property int selectedIndex: 0

  signal actionExecuted(var action)
  signal closeRequested()

  anchors.fill: parent
  color: Qt.rgba(0, 0, 0, 0.45)
  visible: opacity > 0
  opacity: active ? 1.0 : 0.0

  Behavior on opacity {
    NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
  }

  // Dismiss on clicking backdrop
  MouseArea {
    anchors.fill: parent
    onClicked: root.closeRequested()
  }

  // Action Palette Card (Centered bottom popup)
  Rectangle {
    id: card
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 48
    width: 440
    height: Math.min(320, actionList.contentHeight + 64)
    radius: Theme.windowRadius
    color: Theme.darkBackground
    border.color: Theme.border
    border.width: 1

    // Scale animation on reveal
    scale: root.active ? 1.0 : 0.95
    Behavior on scale {
      NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
    }

    Column {
      anchors.fill: parent
      anchors.margins: 8
      spacing: 6

      // Mini action search bar
      Rectangle {
        width: parent.width
        height: 36
        radius: 6
        color: Theme.itemHoverBackground
        border.color: Theme.subtleBorder
        border.width: 1

        Row {
          anchors.fill: parent
          anchors.leftMargin: 10
          anchors.rightMargin: 10
          spacing: 8

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "⚡"
            font.pixelSize: 12
          }

          TextInput {
            id: actionInput
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 30
            font.family: Theme.fontFamily
            font.pixelSize: 13
            color: Theme.brightForeground
            clip: true

            Text {
              anchors.fill: parent
              text: "Search actions..."
              font.family: Theme.fontFamily
              font.pixelSize: 13
              color: Theme.muted
              visible: actionInput.text.length === 0
            }

            onTextChanged: root.filterActions(text)

            Keys.onPressed: event => {
              if (event.key === Qt.Key_Down || (event.key === Qt.Key_N && event.modifiers & Qt.ControlModifier)) {
                root.moveSelection(1)
                event.accepted = true
              } else if (event.key === Qt.Key_Up || (event.key === Qt.Key_P && event.modifiers & Qt.ControlModifier)) {
                root.moveSelection(-1)
                event.accepted = true
              } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.executeSelected()
                event.accepted = true
              } else if (event.key === Qt.Key_Escape) {
                root.closeRequested()
                event.accepted = true
              }
            }
          }
        }
      }

      // Actions List
      ListView {
        id: actionList
        width: parent.width
        height: parent.height - 44
        clip: true
        model: root.filteredActions
        boundsBehavior: Flickable.StopAtBounds

        delegate: Rectangle {
          id: rowDelegate
          width: actionList.width
          height: 38
          radius: Theme.itemRadius
          color: index === root.selectedIndex ? Theme.itemSelectedBackground : (rowMouse.containsMouse ? Theme.itemHoverBackground : "transparent")
          visible: !modelData.isSection

          Row {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: modelData.icon || "•"
              font.family: Theme.fontFamily
              font.pixelSize: 13
              color: modelData.destructive ? "#f07178" : (index === root.selectedIndex ? Theme.accent : Theme.muted)
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width - 90
              text: modelData.title
              font.family: Theme.fontFamily
              font.pixelSize: 13
              font.weight: index === root.selectedIndex ? Font.Medium : Font.Normal
              color: modelData.destructive ? "#f07178" : (index === root.selectedIndex ? Theme.brightForeground : Theme.lightForeground)
              elide: Text.ElideRight
            }

            Item { width: 1; height: 1 } // Spacer

            Rectangle {
              visible: (modelData.shortcut || "").length > 0
              anchors.verticalCenter: parent.verticalCenter
              height: 20
              radius: 4
              color: Theme.itemHoverBackground
              border.color: Theme.border
              border.width: 1
              width: actionShortcutText.implicitWidth + 8

              Text {
                id: actionShortcutText
                anchors.centerIn: parent
                text: modelData.shortcut || ""
                font.family: Theme.monoFontFamily
                font.pixelSize: 9
                color: Theme.muted
              }
            }
          }

          MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              root.selectedIndex = index
              root.executeSelected()
            }
          }
        }
      }
    }
  }

  function open(actionsList) {
    actions = actionsList || []
    filteredActions = actions
    selectedIndex = 0
    actionInput.text = ""
    active = true
    actionInput.forceActiveFocus()
  }

  function filterActions(query) {
    if (!query || query.trim() === "") {
      filteredActions = actions
    } else {
      var scored = []
      for (var i = 0; i < actions.length; i++) {
        var a = actions[i]
        if (a.isSection)
          continue
        var s = Fuzzy.itemScore(query, a)
        if (s > 0)
          scored.push({ item: a, score: s })
      }
      scored.sort(function(a, b) { return b.score - a.score })
      filteredActions = scored.map(function(x) { return x.item })
    }
    selectedIndex = 0
  }

  function moveSelection(delta) {
    if (filteredActions.length === 0) return
    var next = selectedIndex + delta
    if (next < 0) next = filteredActions.length - 1
    if (next >= filteredActions.length) next = 0
    selectedIndex = next
  }

  function executeSelected() {
    if (filteredActions.length > 0 && selectedIndex < filteredActions.length) {
      var action = filteredActions[selectedIndex]
      active = false
      if (typeof action.callback === "function") {
        action.callback()
      }
      root.actionExecuted(action)
    }
  }
}
