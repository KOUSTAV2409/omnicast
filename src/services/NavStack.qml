import QtQuick

QtObject {
  id: root

  // Array of { title: string, icon: string, component: Component, props: var }
  property var stack: []
  property var currentView: stack.length > 0 ? stack[stack.length - 1] : null
  property int depth: stack.length

  readonly property var breadcrumbs: {
    var crumbs = []
    for (var i = 0; i < stack.length; i++) {
      crumbs.push(stack[i].title)
    }
    return crumbs
  }

  signal viewPushed(var viewData)
  signal viewPopped(var viewData)
  signal stackReset()

  function push(title, icon, component, props) {
    var item = {
      title: title || "Omnicast",
      icon: icon || "search",
      component: component,
      props: props || {}
    }
    stack.push(item)
    stackChanged()
    viewPushed(item)
  }

  function pop() {
    if (stack.length > 1) {
      var popped = stack.pop()
      stackChanged()
      viewPopped(popped)
      return true
    }
    return false
  }

  function reset() {
    if (stack.length > 1) {
      stack = [stack[0]]
      stackChanged()
      stackReset()
    }
  }

  function clear() {
    stack = []
    stackChanged()
  }
}
