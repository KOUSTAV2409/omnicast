import QtQuick
import Quickshell
import Quickshell.Wayland
import "services"
import "components"
import "views"

PanelWindow {
  id: root

  property bool isVisible: false

  WlrLayershell.namespace: "omnicast"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: isVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
  exclusionMode: ExclusionMode.Ignore

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  color: "transparent"
  visible: isVisible

  // Component reference for root search view
  property Component rootViewComp: Component {
    RootSearchView {
      onRequestActionPalette: actions => actionPalette.open(actions)
      onRequestPushView: (title, comp) => root.pushSubView(title, comp)
      onRequestPushViewWithProps: (title, comp, props) => root.pushSubViewWithProps(title, comp, props)
      onRequestDismiss: root.dismiss()
    }
  }

  // Click outside to dismiss backdrop
  MouseArea {
    anchors.fill: parent
    onClicked: root.dismiss()
  }

  // The Main Floating Modal Card
  Rectangle {
    id: windowCard
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: -40

    width: 760
    height: 480
    radius: Theme.windowRadius
    color: Theme.cardBackground
    border.color: Theme.border
    border.width: 1
    clip: true

    MouseArea {
      anchors.fill: parent
    }

    Column {
      anchors.fill: parent

      // 1. Top Search Bar
      SearchBar {
        id: searchBar
        width: parent.width
        breadcrumbText: navStack.depth > 1 ? navStack.views.map(function(v) { return v.title }).join(" > ") : ""

        onTextChangedByUser: text => {
          if (!actionPalette.active && navStack.currentViewItem && typeof navStack.currentViewItem.filter === "function") {
            navStack.currentViewItem.filter(text)
          }
        }

        onClearRequested: {
          if (navStack.currentViewItem && typeof navStack.currentViewItem.filter === "function") {
            navStack.currentViewItem.filter("")
          }
        }

        onEscapePressed: {
          if (actionPalette.active) {
            actionPalette.active = false
            searchBar.setFocus()
          } else if (navStack.pop()) {
            searchBar.clear()
            searchBar.setFocus()
          } else {
            root.dismiss()
          }
        }

        onActionPaletteRequested: {
          if (navStack.currentViewItem && typeof navStack.currentViewItem.openActionPalette === "function") {
            navStack.currentViewItem.openActionPalette()
          }
        }

        onSubmitPressed: {
          if (actionPalette.active) {
            actionPalette.executeSelected()
          } else if (navStack.currentViewItem && typeof navStack.currentViewItem.executeCurrent === "function") {
            navStack.currentViewItem.executeCurrent()
          }
        }

        onMoveDownRequested: {
          if (actionPalette.active) actionPalette.moveSelection(1)
          else if (navStack.currentViewItem && typeof navStack.currentViewItem.moveSelection === "function") {
            navStack.currentViewItem.moveSelection(1)
          }
        }

        onMoveUpRequested: {
          if (actionPalette.active) actionPalette.moveSelection(-1)
          else if (navStack.currentViewItem && typeof navStack.currentViewItem.moveSelection === "function") {
            navStack.currentViewItem.moveSelection(-1)
          }
        }
      }

      // 2. Middle Dynamic Navigation Stack Container
      Item {
        id: viewContainer
        width: parent.width
        height: parent.height - searchBar.height - footerBar.height

        NavigationStack {
          id: navStack
          anchors.fill: parent

          onTopViewChanged: viewInfo => {
            searchBar.clear()
            Qt.callLater(searchBar.setFocus)
          }
        }
      }

      // 3. Bottom Footer Bar
      FooterBar {
        id: footerBar
        width: parent.width
        primaryActionText: {
          var item = navStack.currentViewItem ? navStack.currentViewItem.selectedItem : null
          if (item) {
            return item.category === "Applications" ? "Open App" : (item.badge === "Theme" ? "Apply Theme" : (item.badge === "Script" ? "Run Script" : "Select"))
          }
          return "Select"
        }
        subtitleText: {
          var item = navStack.currentViewItem ? navStack.currentViewItem.selectedItem : null
          if (item && item.category) return item.category
          if (navStack.views.length > 0) return navStack.views[navStack.views.length - 1].title
          return "Omnicast"
        }
        canPop: navStack.depth > 1

        onPrimaryActionClicked: {
          if (navStack.currentViewItem && typeof navStack.currentViewItem.executeCurrent === "function") {
            navStack.currentViewItem.executeCurrent()
          }
        }

        onActionPaletteClicked: {
          if (navStack.currentViewItem && typeof navStack.currentViewItem.openActionPalette === "function") {
            navStack.currentViewItem.openActionPalette()
          }
        }
      }
    }

    // 4. Action Palette Modal Sheet (Ctrl+K) with highest Z-index
    ActionPalette {
      id: actionPalette
      z: 100
      onCloseRequested: {
        active = false
        searchBar.setFocus()
      }
      onActionExecuted: action => {
        searchBar.setFocus()
      }
    }
  }

  function pushSubView(title, component) {
    pushSubViewWithProps(title, component, {})
  }

  function pushSubViewWithProps(title, component, customProps) {
    var props = customProps || {}
    props.navStack = root.navStack
    navStack.push(title, component, props)
    if (navStack.currentViewItem) {
      if ("requestActionPalette" in navStack.currentViewItem) {
        navStack.currentViewItem.requestActionPalette.connect(function(actions) {
          actionPalette.open(actions)
        })
      }
      if ("requestDismiss" in navStack.currentViewItem) {
        navStack.currentViewItem.requestDismiss.connect(function() {
          root.dismiss()
        })
      }
    }
  }

  function show() {
    isVisible = true
    if (navStack.depth === 0) {
      navStack.push("Omnicast", rootViewComp)
    }
    searchBar.clear()
    Qt.callLater(searchBar.setFocus)
  }

  function dismiss() {
    isVisible = false
    actionPalette.active = false
    navStack.reset()
    searchBar.clear()
  }

  function toggle() {
    if (isVisible) dismiss()
    else show()
  }
}
