import QtQuick
import "../services"

Item {
  id: root

  property var views: [] // Array of { title: string, item: Item }
  property Item currentViewItem: null
  readonly property int depth: views.length

  signal topViewChanged(var viewInfo)

  function push(title, itemComponent, props) {
    if (!itemComponent) {
      console.error("[NavigationStack] Null component passed to push:", title)
      return
    }

    var instance = itemComponent.createObject(container, props || {})
    if (!instance) {
      console.error("[NavigationStack] Failed to instantiate component for:", title)
      return
    }

    instance.anchors.fill = container
    instance.visible = true

    var oldItem = currentViewItem
    var viewEntry = {
      title: title,
      item: instance
    }

    views.push(viewEntry)
    viewsChanged()
    currentViewItem = instance
    topViewChanged(viewEntry)

    // Smooth transition
    instance.opacity = 0.0
    var animIn = Qt.createQmlObject('import QtQuick; NumberAnimation { duration: 160; easing.type: Easing.OutCubic; property: "opacity"; to: 1.0 }', instance)
    animIn.target = instance
    animIn.start()

    if (oldItem) {
      oldItem.visible = false
    }
  }

  function pop() {
    if (views.length <= 1) return false

    var poppedEntry = views.pop()
    viewsChanged()
    var poppedItem = poppedEntry.item
    var nextEntry = views[views.length - 1]
    var nextItem = nextEntry.item

    currentViewItem = nextItem
    nextItem.visible = true
    nextItem.opacity = 1.0
    topViewChanged(nextEntry)

    poppedItem.destroy()
    return true
  }

  function reset() {
    while (views.length > 1) {
      var entry = views.pop()
      entry.item.destroy()
    }
    viewsChanged()
    if (views.length === 1) {
      currentViewItem = views[0].item
      currentViewItem.visible = true
      currentViewItem.opacity = 1.0
      topViewChanged(views[0])
    }
  }

  Item {
    id: container
    anchors.fill: parent
  }
}
