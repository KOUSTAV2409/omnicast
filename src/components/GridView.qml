import QtQuick
import "../services"
import "../components"

Item {
  id: root

  property var items: []
  property var filteredItems: []
  property int selectedIndex: 0
  property int columns: 4
  property int cellSpacing: 10

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
               (it.subtitle && it.subtitle.toLowerCase().includes(q))
      })
    }
    selectedIndex = Math.min(selectedIndex, Math.max(0, filteredItems.length - 1))
  }

  function moveSelectionHorizontal(delta) {
    if (filteredItems.length === 0) return
    var next = selectedIndex + delta
    if (next < 0) next = filteredItems.length - 1
    if (next >= filteredItems.length) next = 0
    selectedIndex = next
    grid.positionViewAtIndex(selectedIndex, GridView.Contain)
  }

  function moveSelectionVertical(delta) {
    if (filteredItems.length === 0) return
    var next = selectedIndex + (delta * columns)
    if (next < 0) next = Math.max(0, filteredItems.length - 1)
    if (next >= filteredItems.length) next = Math.min(selectedIndex % columns, filteredItems.length - 1)
    selectedIndex = next
    grid.positionViewAtIndex(selectedIndex, GridView.Contain)
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

  GridView {
    id: grid
    anchors.fill: parent
    anchors.margins: 12
    cellWidth: Math.floor(width / root.columns)
    cellHeight: 130
    clip: true
    model: root.filteredItems
    boundsBehavior: Flickable.StopAtBounds

    delegate: Item {
      width: grid.cellWidth
      height: grid.cellHeight

      GridCard {
        anchors.fill: parent
        anchors.margins: 4
        title: modelData.title || ""
        subtitle: modelData.subtitle || ""
        iconText: modelData.icon || ""
        previewColor: modelData.color || ""
        imageSource: modelData.image || ""
        badgeText: modelData.badge || ""
        isSelected: index === root.selectedIndex

        onClicked: {
          root.selectedIndex = index
          root.executeCurrent()
        }
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
