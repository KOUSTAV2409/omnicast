import QtQuick
import "../services"

Rectangle {
  id: root

  property string title: ""
  property string subtitle: ""
  property var fields: []
  property var formValues: ({})
  property int activeFieldIndex: 0
  property bool interceptsSearch: true
  property var submitHandler: null

  signal formSubmitted(var values)
  signal formCancelled()
  signal requestActionPalette(var actions)
  signal requestDismiss()

  readonly property var selectedItem: ({
    primaryActionTitle: "Submit",
    category: "Form"
  })

  color: "transparent"

  Flickable {
    id: scrollArea
    anchors.fill: parent
    anchors.margins: 18
    contentWidth: width
    contentHeight: formColumn.implicitHeight + 60
    clip: true

    Column {
      id: formColumn
      width: parent.width
      spacing: 16

      Column {
        width: parent.width
        spacing: 4

        Text {
          text: root.title
          font.family: Theme.fontFamily
          font.pixelSize: 17
          font.weight: Font.DemiBold
          color: Theme.brightForeground
        }

        Text {
          visible: root.subtitle.length > 0
          text: root.subtitle
          font.family: Theme.fontFamily
          font.pixelSize: 12
          color: Theme.muted
        }
      }

      Rectangle {
        width: parent.width
        height: 1
        color: Theme.border
      }

      Repeater {
        id: fieldRepeater
        model: root.fields

        delegate: Column {
          width: formColumn.width
          spacing: 6

          Text {
            text: modelData.label
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
            color: index === root.activeFieldIndex ? Theme.accent : Theme.lightForeground
          }

          Rectangle {
            visible: modelData.type === "text" || modelData.type === "password" || !modelData.type
            width: parent.width
            height: 38
            radius: 6
            color: index === root.activeFieldIndex ? Theme.itemHoverBackground : Theme.cardBackground
            border.color: index === root.activeFieldIndex ? Theme.accent : Theme.border
            border.width: 1

            TextInput {
              id: textInput
              anchors.fill: parent
              anchors.margins: 10
              font.family: Theme.fontFamily
              font.pixelSize: 13
              color: Theme.brightForeground
              echoMode: modelData.type === "password" ? TextInput.Password : TextInput.Normal
              text: root.formValues[modelData.id] !== undefined ? root.formValues[modelData.id] : (modelData.defaultValue || "")
              focus: index === 0

              Text {
                anchors.fill: parent
                text: modelData.placeholder || ""
                font.family: Theme.fontFamily
                font.pixelSize: 13
                color: Theme.muted
                visible: textInput.text.length === 0 && !textInput.activeFocus
              }

              onTextChanged: {
                var v = Object.assign({}, root.formValues)
                v[modelData.id] = text
                root.formValues = v
              }

              onActiveFocusChanged: {
                if (activeFocus)
                  root.activeFieldIndex = index
              }

              Keys.onPressed: event => {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                  root.submit()
                  event.accepted = true
                } else if (event.key === Qt.Key_Tab) {
                  root.moveSelection(1)
                  event.accepted = true
                } else if (event.key === Qt.Key_Backtab) {
                  root.moveSelection(-1)
                  event.accepted = true
                }
              }
            }
          }

          Row {
            visible: modelData.type === "toggle"
            width: parent.width
            spacing: 12

            Rectangle {
              id: switchTrack
              width: 36
              height: 20
              radius: 10
              color: (root.formValues[modelData.id] || false) ? Theme.accent : Theme.border

              Rectangle {
                width: 16
                height: 16
                radius: 8
                color: Theme.brightForeground
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: (root.formValues[modelData.id] || false) ? undefined : parent.left
                anchors.right: (root.formValues[modelData.id] || false) ? parent.right : undefined
                anchors.margins: 2
              }

              MouseArea {
                anchors.fill: parent
                onClicked: {
                  var v = Object.assign({}, root.formValues)
                  v[modelData.id] = !(v[modelData.id] || false)
                  root.formValues = v
                }
              }
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: modelData.description || ""
              font.family: Theme.fontFamily
              font.pixelSize: 12
              color: Theme.muted
            }
          }
        }
      }

      Row {
        width: parent.width
        spacing: 10

        Rectangle {
          height: 36
          radius: 6
          color: Theme.accent
          width: submitLabel.implicitWidth + 24

          Text {
            id: submitLabel
            anchors.centerIn: parent
            text: "Submit (↵)"
            font.family: Theme.fontFamily
            font.pixelSize: 13
            font.weight: Font.DemiBold
            color: Theme.darkerBackground
          }

          MouseArea {
            anchors.fill: parent
            onClicked: root.submit()
          }
        }
      }
    }
  }

  function submit() {
    root.formSubmitted(root.formValues)
    if (typeof root.submitHandler === "function")
      root.submitHandler(root.formValues)
  }

  function filter(query) {
    // Forms intercept search — ignore filtering
  }

  function moveSelection(delta) {
    if (!fields || fields.length === 0)
      return
    var next = activeFieldIndex + delta
    if (next < 0)
      next = fields.length - 1
    if (next >= fields.length)
      next = 0
    activeFieldIndex = next
  }

  function executeCurrent() {
    submit()
  }

  function openActionPalette() {
    root.requestActionPalette([
      { title: "Submit Form", icon: "↵", shortcut: "↵", callback: function() { root.submit() } },
      { title: "Cancel", icon: "✕", callback: function() { root.formCancelled() } }
    ])
  }

  function focusActiveField() {
    // Best-effort: TextInputs get focus via activeFieldIndex styling; user Tabs between
  }

  Component.onCompleted: {
    var init = ({})
    for (var i = 0; i < fields.length; i++)
      init[fields[i].id] = fields[i].defaultValue || ""
    formValues = init
  }
}
