import QtQuick
import "../services"

Rectangle {
  id: root

  property string title: ""
  property string markdownContent: ""
  property var metadata: [] // Array of { label: string, value: string }
  property string imageSource: ""
  property string headerBadge: ""
  property string swatchColor: ""

  color: "transparent"

  Flickable {
    id: scrollArea
    anchors.fill: parent
    anchors.margins: 16
    contentWidth: width
    contentHeight: contentColumn.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    Column {
      id: contentColumn
      width: parent.width
      spacing: 14

      // Header row (if title provided)
      Row {
        visible: root.title.length > 0
        width: parent.width
        spacing: 8

        Text {
          width: parent.width - (headerBadgeRect.visible ? headerBadgeRect.width + 12 : 0)
          text: root.title
          font.family: Theme.fontFamily
          font.pixelSize: 16
          font.weight: Font.DemiBold
          color: Theme.brightForeground
          elide: Text.ElideRight
        }

        Rectangle {
          id: headerBadgeRect
          visible: root.headerBadge.length > 0
          anchors.verticalCenter: parent.verticalCenter
          height: 20
          radius: 4
          color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2)
          border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.5)
          border.width: 1
          width: headerBadgeLabel.implicitWidth + 10

          Text {
            id: headerBadgeLabel
            anchors.centerIn: parent
            text: root.headerBadge
            font.family: Theme.fontFamily
            font.pixelSize: 10
            font.weight: Font.Medium
            color: Theme.accent
          }
        }
      }

      // Optional color swatch
      Rectangle {
        visible: root.swatchColor.length > 0
        width: parent.width
        height: 72
        radius: 8
        color: root.swatchColor
        border.color: Theme.border
        border.width: 1
      }

      // Optional Image Thumbnail Preview
      Rectangle {
        visible: root.imageSource.length > 0
        width: parent.width
        height: 140
        radius: 8
        color: Theme.itemHoverBackground
        border.color: Theme.subtleBorder
        border.width: 1
        clip: true

        Image {
          anchors.fill: parent
          anchors.margins: 4
          source: root.imageSource
          fillMode: Image.PreserveAspectFit
          asynchronous: true
        }
      }

      // Markdown / Body Content
      Text {
        visible: root.markdownContent.length > 0
        width: parent.width
        text: root.markdownContent
        textFormat: Text.MarkdownText
        font.family: Theme.fontFamily
        font.pixelSize: 13
        lineHeight: 1.4
        color: Theme.lightForeground
        wrapMode: Text.WordWrap
      }

      // Metadata Key-Value Property Table
      Column {
        visible: root.metadata && root.metadata.length > 0
        width: parent.width
        spacing: 6

        Rectangle {
          width: parent.width
          height: 1
          color: Theme.subtleBorder
        }

        Text {
          text: "METADATA"
          font.family: Theme.fontFamily
          font.pixelSize: 10
          font.weight: Font.Bold
          font.letterSpacing: 1.0
          color: Theme.muted
        }

        Repeater {
          model: root.metadata
          delegate: Row {
            width: parent.width
            spacing: 8

            Text {
              width: 110
              text: modelData.label || ""
              font.family: Theme.fontFamily
              font.pixelSize: 11
              color: Theme.muted
              elide: Text.ElideRight
            }

            Text {
              width: parent.width - 120
              text: modelData.value || ""
              font.family: Theme.fontFamily
              font.pixelSize: 12
              font.weight: Font.Medium
              color: Theme.lightForeground
              elide: Text.ElideRight
            }
          }
        }
      }
    }
  }
}
