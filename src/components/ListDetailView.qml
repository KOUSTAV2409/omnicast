import QtQuick
import "../services"
import "../components"

Item {
  id: root

  property var items: []
  property var filteredItems: []
  property int selectedIndex: 0
  property real listWidthRatio: 0.44 // 44% list, 56% detail

  signal itemExecuted(var item)
  signal requestActionPalette(var actions)

  readonly property var selectedItem: filteredItems.length > 0 && selectedIndex < filteredItems.length ? filteredItems[selectedIndex] : null

  function filter(query) {
    if (!query || query.trim() === "") {
      filteredItems = items
    } else {
      var q = query.toLowerCase()
      filteredItems = items.filter(function(it) {
        return (it.title && it.title.toLowerCase().includes(q)) ||
               (it.subtitle && it.subtitle.toLowerCase().includes(q)) ||
               (it.markdown && it.markdown.toLowerCase().includes(q))
      })
    }
    if (filteredItems.length > 0) {
      selectedIndex = Math.min(selectedIndex, filteredItems.length - 1)
      if (selectedIndex < 0) selectedIndex = 0
    } else {
      selectedIndex = 0
    }
  }

  function moveSelection(delta) {
    if (filteredItems.length === 0) return
    var next = selectedIndex + delta
    if (next < 0) next = filteredItems.length - 1
    if (next >= filteredItems.length) next = 0
    selectedIndex = next
    listView.currentIndex = selectedIndex
    listView.positionViewAtIndex(selectedIndex, ListView.Contain)
  }

  function executeCurrent() {
    if (selectedItem) {
      if (typeof selectedItem.action === "function") selectedItem.action()
      root.itemExecuted(selectedItem)
    }
  }

  function openActionPalette() {
    if (selectedItem && selectedItem.actions) {
      root.requestActionPalette(selectedItem.actions)
    }
  }

  Row {
    anchors.fill: parent

    // Left Column: Items List
    Item {
      width: Math.round(parent.width * root.listWidthRatio)
      height: parent.height

      ListView {
        id: listView
        anchors.fill: parent
        anchors.margins: 8
        clip: true
        model: root.filteredItems
        currentIndex: root.selectedIndex
        boundsBehavior: Flickable.StopAtBounds

        delegate: ItemRow {
          width: listView.width
          title: modelData.title || ""
          subtitle: modelData.subtitle || ""
          iconText: modelData.icon || "•"
          badgeText: modelData.badge || ""
          shortcutHint: modelData.shortcut || ""
          isSelected: index === root.selectedIndex

          onClicked: {
            root.selectedIndex = index
            root.executeCurrent()
          }
        }
      }

      // Empty State in Left Pane
      EmptyState {
        visible: root.filteredItems.length === 0
        title: "No Matching Items"
        subtitle: "No items match your search filter"
      }
    }

    // Middle Vertical Divider Line
    Rectangle {
      width: 1
      height: parent.height
      color: Theme.border
    }

    // Right Column: Live Rich Detail Pane
    Item {
      width: parent.width - Math.round(parent.width * root.listWidthRatio) - 1
      height: parent.height

      DetailPane {
        id: detailPane
        anchors.fill: parent
        title: root.selectedItem ? (root.selectedItem.title || "") : ""
        headerBadge: root.selectedItem ? (root.selectedItem.badge || "") : ""
        markdownContent: root.selectedItem ? (root.selectedItem.markdown || root.selectedItem.subtitle || "") : (root.filteredItems.length === 0 ? "*No item selected.*" : "Select an item from the list to view its details.")
        metadata: root.selectedItem ? (root.selectedItem.metadata || []) : []
        imageSource: root.selectedItem ? (root.selectedItem.image || "") : ""
      }
    }
  }

  onItemsChanged: {
    filter("")
  }

  Component.onCompleted: {
    filter("")
  }
}
