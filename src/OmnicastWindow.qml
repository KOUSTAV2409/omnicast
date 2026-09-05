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

  property Component rootViewComp: Component {
    RootSearchView {
      onRequestActionPalette: actions => actionPalette.open(actions)
      onRequestPushView: (title, comp) => root.pushSubView(title, comp)
      onRequestPushViewWithProps: (title, comp, props) => root.pushSubViewWithProps(title, comp, props)
      onRequestDismiss: root.dismissWithHud()
      onIsLoadingChanged: searchBar.busy = isLoading
    }
  }

  // Omarchy-style scrim behind the card
  Rectangle {
    anchors.fill: parent
    color: Theme.scrim
    visible: root.isVisible
    opacity: root.isVisible ? 1 : 0
  }

  MouseArea {
    anchors.fill: parent
    onClicked: root.dismiss()
  }

  Rectangle {
    id: windowCard
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter

    width: {
      var v = navStack.currentViewItem
      return (v && v.wideLayout) ? Math.max(Theme.cardWidth, 720) : Theme.cardWidth
    }
    height: {
      var v = navStack.currentViewItem
      return (v && v.wideLayout) ? Math.max(Theme.cardHeight, 640) : Theme.cardHeight
    }

    Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
    radius: Theme.windowRadius
    color: Theme.darkerBackground
    border.color: Theme.border
    border.width: Math.max(1, Theme.windowRadius > 0 ? 1 : 2)
    clip: true

    Rectangle {
      anchors.fill: parent
      anchors.margins: windowCard.border.width > 0 ? 0 : 0
      radius: parent.radius
      color: Theme.cardBackground
    }

    MouseArea {
      anchors.fill: parent
    }

    Column {
      id: cardColumn
      anchors.fill: parent
      anchors.margins: Theme.panelPadding
      spacing: Theme.contentSpacing

      SearchBar {
        id: searchBar
        width: parent.width
        breadcrumbText: navStack.depth > 1 ? navStack.views.map(function(v) { return v.title }).join(" › ") : ""

        onTextChangedByUser: text => {
          var view = navStack.currentViewItem
          if (!view)
            return
          if (view.interceptsSearch)
            return
          if (!actionPalette.active && typeof view.filter === "function")
            view.filter(text)
        }

        onClearRequested: {
          var view = navStack.currentViewItem
          if (view && !view.interceptsSearch && typeof view.filter === "function")
            view.filter("")
        }

        onEscapePressed: {
          if (actionPalette.active) {
            actionPalette.active = false
            searchBar.setFocus()
          } else if (toast.active) {
            toast.hide()
          } else if (navStack.pop()) {
            searchBar.clear()
            searchBar.setFocus()
          } else {
            root.dismiss()
          }
        }

        onActionPaletteRequested: {
          if (navStack.currentViewItem && typeof navStack.currentViewItem.openActionPalette === "function")
            navStack.currentViewItem.openActionPalette()
        }

        onSubmitPressed: {
          if (actionPalette.active) {
            actionPalette.executeSelected()
          } else if (navStack.currentViewItem && typeof navStack.currentViewItem.executeCurrent === "function") {
            navStack.currentViewItem.executeCurrent()
          }
        }

        onMoveDownRequested: {
          if (actionPalette.active)
            actionPalette.moveSelection(1)
          else if (navStack.currentViewItem && typeof navStack.currentViewItem.moveSelection === "function")
            navStack.currentViewItem.moveSelection(1)
        }

        onMoveUpRequested: {
          if (actionPalette.active)
            actionPalette.moveSelection(-1)
          else if (navStack.currentViewItem && typeof navStack.currentViewItem.moveSelection === "function")
            navStack.currentViewItem.moveSelection(-1)
        }

        onCategoryCycleRequested: {
          var view = navStack.currentViewItem
          if (view && typeof view.cycleCategory === "function")
            view.cycleCategory(1)
        }
      }

      Item {
        id: viewContainer
        width: parent.width
        height: parent.height - searchBar.height - footerBar.height - Theme.contentSpacing * 2

        NavigationStack {
          id: navStack
          anchors.fill: parent

          onTopViewChanged: viewInfo => {
            searchBar.clear()
            var view = navStack.currentViewItem
            if (view && view.interceptsSearch) {
              Qt.callLater(function() {})
            } else {
              Qt.callLater(searchBar.setFocus)
            }
            searchBar.busy = !!(view && view.isLoading)
          }
        }
      }

      FooterBar {
        id: footerBar
        width: parent.width
        primaryActionText: {
          var item = navStack.currentViewItem ? navStack.currentViewItem.selectedItem : null
          if (item && item.primaryActionTitle)
            return item.primaryActionTitle
          return "Select"
        }
        subtitleText: {
          var item = navStack.currentViewItem ? navStack.currentViewItem.selectedItem : null
          if (item && item.badge) return item.badge
          if (navStack.views.length > 0) return navStack.views[navStack.views.length - 1].title
          return "Omnicast"
        }
        canPop: navStack.depth > 1

        onPrimaryActionClicked: {
          if (navStack.currentViewItem && typeof navStack.currentViewItem.executeCurrent === "function")
            navStack.currentViewItem.executeCurrent()
        }

        onActionPaletteClicked: {
          if (navStack.currentViewItem && typeof navStack.currentViewItem.openActionPalette === "function")
            navStack.currentViewItem.openActionPalette()
        }
      }
    }

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

    Toast {
      id: toast
      anchors.horizontalCenter: parent.horizontalCenter
      onCopyRequested: {
        Exec.copyText(toast.detail)
        Hud.success("Copied error")
      }
    }
  }

  HudOverlay {
    // HUD moved to HudPanel (shell-level) so it survives dismiss
    visible: false
  }

  function wireView(view) {
    if (!view)
      return
    if ("requestActionPalette" in view) {
      view.requestActionPalette.connect(function(actions) {
        actionPalette.open(actions)
      })
    }
    if ("requestDismiss" in view) {
      view.requestDismiss.connect(function() {
        root.dismissWithHud()
      })
    }
    if ("requestPushView" in view) {
      view.requestPushView.connect(function(title, comp) {
        root.pushSubView(title, comp)
      })
    }
    if ("requestPushViewWithProps" in view) {
      view.requestPushViewWithProps.connect(function(title, comp, props) {
        root.pushSubViewWithProps(title, comp, props)
      })
    }
    if ("isLoadingChanged" in view) {
      view.isLoadingChanged.connect(function() {
        searchBar.busy = !!view.isLoading
      })
    }
  }

  function pushSubView(title, component) {
    pushSubViewWithProps(title, component, {})
  }

  function pushSubViewWithProps(title, component, customProps) {
    var props = {}
    var src = customProps || {}
    for (var k in src)
      props[k] = src[k]
    props.navStack = navStack

    // onFormSubmitted collides with signal handler naming: extract first
    var formCb = props.onFormSubmitted || props.submitHandler || null
    delete props.onFormSubmitted
    delete props.submitHandler

    navStack.push(title, component, props)
    wireView(navStack.currentViewItem)
    if (formCb && navStack.currentViewItem) {
      if ("submitHandler" in navStack.currentViewItem)
        navStack.currentViewItem.submitHandler = formCb
      else if (navStack.currentViewItem.formSubmitted)
        navStack.currentViewItem.formSubmitted.connect(formCb)
    }
  }

  function show() {
    isVisible = true
    Ranking.reload()
    if (navStack.depth === 0) {
      navStack.push("Omnicast", rootViewComp)
      wireView(navStack.currentViewItem)
    }
    searchBar.clear()
    Qt.callLater(function() {
      searchBar.setFocus()
      if (searchBar.textInput)
        searchBar.textInput.forceActiveFocus()
    })
  }

  function dismiss() {
    isVisible = false
    actionPalette.active = false
    toast.hide()
    // Keep root view warm so Omarchy/app catalogs aren't rescanned every open
    while (navStack.depth > 1)
      navStack.pop()
    searchBar.clear()
    if (navStack.currentViewItem && typeof navStack.currentViewItem.filter === "function")
      navStack.currentViewItem.filter("")
  }

  // Allow pending Hud to show after window hides
  function dismissWithHud() {
    dismiss()
  }

  function toggle() {
    if (isVisible)
      dismiss()
    else
      show()
  }

  function showToast(msg, detail) {
    toast.show(msg, detail || "")
  }
}
