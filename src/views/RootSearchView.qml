import QtQuick
import Quickshell
import Quickshell.Io
import "../services"
import "../components"

Item {
  id: root

  property var navStack: null
  property string filterText: ""
  property int selectedIndex: 0
  property var allItems: []
  property var filteredItems: []
  property var scriptCommands: []
  property var omarchyCommands: []
  property var desktopApps: []

  signal requestActionPalette(var actions)
  signal requestPushView(string title, var component)
  signal requestPushViewWithProps(string title, var component, var props)
  signal requestDismiss()

  readonly property var selectedItem: filteredItems.length > 0 && selectedIndex < filteredItems.length ? filteredItems[selectedIndex] : null

  // Sub-view Components
  property Component clipboardViewComp: Qt.createComponent("ClipboardView.qml")
  property Component themePickerComp: Qt.createComponent("ThemePickerView.qml")
  property Component windowTilerComp: Qt.createComponent("WindowTilerView.qml")
  property Component snippetsComp: Qt.createComponent("SnippetsView.qml")
  property Component aiAssistComp: Qt.createComponent("AiAssistView.qml")
  property Component scriptResultComp: Qt.createComponent("ScriptResultView.qml")
  property Component formViewComp: Qt.createComponent("../components/FormView.qml")

  // Process to scan for custom script commands
  property Process scriptScanner: Process {
    command: ["python3", "/home/iamkxyz/Projects/omnicast/src/backend/script_runner.py", "scan"]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => root.handleScriptScan(text)
    }
  }

  // Process to scan native Omarchy system commands
  property Process omarchyScanner: Process {
    command: ["python3", "/home/iamkxyz/Projects/omnicast/src/backend/omarchy_commands.py"]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => root.handleOmarchyScan(text)
    }
  }

  // Process to index installed desktop apps dynamically
  property Process appScanner: Process {
    command: ["python3", "/home/iamkxyz/Projects/omnicast/src/backend/app_indexer.py"]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => root.handleAppScan(text)
    }
  }

  function handleOmarchyScan(raw) {
    try {
      var cmds = JSON.parse(raw || "[]")
      omarchyCommands = []
      for (var i = 0; i < cmds.length; i++) {
        var c = cmds[i]
        omarchyCommands.push({
          id: c.id,
          title: c.title,
          subtitle: c.subtitle || ("Execute " + c.route),
          icon: c.icon || "⚙️",
          category: c.category || "Omarchy",
          badge: "Omarchy",
          route: c.route,
          action: (function(cmdRoute) {
            return function() {
              Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "' + cmdRoute.replace(/'/g, "'\\''") + ' &"]; running: true }', root)
              root.requestDismiss()
            }
          })(c.route),
          actions: [
            {
              title: "Run Command",
              icon: "⚡",
              shortcut: "↵",
              callback: (function(cmdRoute) {
                return function() {
                  Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "' + cmdRoute.replace(/'/g, "'\\''") + ' &"]; running: true }', root)
                  root.requestDismiss()
                }
              })(c.route)
            },
            {
              title: "Run in Terminal",
              icon: "",
              callback: (function(cmdRoute) {
                return function() {
                  Qt.createQmlObject('import Quickshell.Io; Process { command: ["ghostty", "-e", "bash", "-c", "' + cmdRoute.replace(/'/g, "'\\''") + '; echo; read -p \\"Press enter to close...\\""]; running: true }', root)
                  root.requestDismiss()
                }
              })(c.route)
            }
          ]
        })
      }
      buildFullItemList()
    } catch (e) {
      console.error("Error parsing Omarchy commands:", e)
      buildFullItemList()
    }
  }

  function handleAppScan(raw) {
    try {
      var apps = JSON.parse(raw || "[]")
      desktopApps = []
      for (var i = 0; i < apps.length; i++) {
        var a = apps[i]
        desktopApps.push({
          id: a.id,
          title: a.title,
          subtitle: a.subtitle || "Application",
          icon: a.icon || "",
          category: "Applications",
          badge: "App",
          exec: a.exec,
          desktopPath: a.desktop_path,
          action: (function(appExec) {
            return function() {
              Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "' + appExec.replace(/'/g, "'\\''") + ' &"]; running: true }', root)
              root.requestDismiss()
            }
          })(a.exec),
          actions: [
            {
              title: "Launch Application",
              icon: "🚀",
              shortcut: "↵",
              callback: (function(appExec) {
                return function() {
                  Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "' + appExec.replace(/'/g, "'\\''") + ' &"]; running: true }', root)
                  root.requestDismiss()
                }
              })(a.exec)
            },
            {
              title: "Launch in Terminal",
              icon: "",
              callback: (function(appExec) {
                return function() {
                  Qt.createQmlObject('import Quickshell.Io; Process { command: ["ghostty", "-e", "' + appExec.replace(/'/g, "'\\''") + '"]; running: true }', root)
                  root.requestDismiss()
                }
              })(a.exec)
            }
          ]
        })
      }
      buildFullItemList()
    } catch (e) {
      console.error("Error parsing app indexer output:", e)
      buildFullItemList()
    }
  }

  function handleScriptScan(raw) {
    try {
      var scripts = JSON.parse(raw || "[]")
      scriptCommands = []
      for (var i = 0; i < scripts.length; i++) {
        var s = scripts[i]
        scriptCommands.push({
          id: s.id,
          title: s.title,
          subtitle: s.subtitle || "Script Command",
          icon: s.icon || "⚡",
          category: s.category || "Script Commands",
          badge: "Script",
          path: s.path,
          arguments: s.arguments || [],
          action: (function(scriptItem) {
            return function() { root.runScriptCommand(scriptItem) }
          })(s),
          actions: [
            {
              title: "Run Script",
              icon: "⚡",
              shortcut: "↵",
              callback: (function(scriptItem) {
                return function() { root.runScriptCommand(scriptItem) }
              })(s)
            }
          ]
        })
      }
      buildFullItemList()
    } catch (e) {
      console.error("Error parsing script scanner output:", e)
      buildFullItemList()
    }
  }

  function runScriptCommand(s) {
    if (s.arguments && s.arguments.length > 0) {
      var formFields = []
      for (var j = 0; j < s.arguments.length; j++) {
        var a = s.arguments[j]
        formFields.push({
          id: a.name || ("arg" + (j+1)),
          label: a.name ? a.name.toUpperCase() : "Argument " + (j+1),
          type: a.type || "text",
          placeholder: a.placeholder || "Enter value..."
        })
      }

      root.requestPushViewWithProps(s.title + " (Inputs)", root.formViewComp, {
        title: s.title,
        subtitle: "Provide required arguments to execute script.",
        fields: formFields,
        onFormSubmitted: function(values) {
          var argsList = Object.values(values)
          root.requestPushViewWithProps(s.title, root.scriptResultComp, {
            scriptTitle: s.title,
            scriptPath: s.path,
            scriptArgs: argsList
          })
        }
      })
    } else {
      root.requestPushViewWithProps(s.title, root.scriptResultComp, {
        scriptTitle: s.title,
        scriptPath: s.path
      })
    }
  }

  function tryMathEvaluation(query) {
    if (!query) return null
    var clean = query.trim()
    if (/^[0-9\.\s\+\-\*\/\(\)\%\^eE]+$/.test(clean) && /[0-9]/.test(clean) && /[\+\-\*\/\%\^]/.test(clean)) {
      try {
        var sanitized = clean.replace(/\^/g, "**")
        var result = Function('"use strict"; return (' + sanitized + ')')()
        if (result !== undefined && typeof result === "number" && isFinite(result)) {
          var formatted = Number.isInteger(result) ? result.toLocaleString() : result.toFixed(4).replace(/\.?0+$/, "")
          return formatted
        }
      } catch (e) {}
    }
    return null
  }

  function buildFullItemList() {
    var items = [
      // Section: POWER TOOLS
      { section: "POWER TOOLS", isHeader: true, title: "POWER TOOLS" },
      {
        id: "clipboard",
        title: "Clipboard History",
        subtitle: "Search and paste copied text, images, and color codes (Omarchy Native)",
        icon: "📋",
        category: "Productivity",
        badge: "Built-in",
        shortcut: "Ctrl+Shift+V",
        action: function() { root.requestPushView("Clipboard History", root.clipboardViewComp) },
        actions: [
          { title: "Open Clipboard View", icon: "📋", shortcut: "↵", callback: function() { root.requestPushView("Clipboard History", root.clipboardViewComp) } }
        ]
      },
      {
        id: "theme",
        title: "Change Theme",
        subtitle: "Browse & switch Omarchy global desktop themes",
        icon: "🎨",
        category: "Appearance",
        badge: "Omarchy",
        action: function() { root.requestPushView("Theme Selector", root.themePickerComp) },
        actions: [
          { title: "Open Theme Selector", icon: "🎨", shortcut: "↵", callback: function() { root.requestPushView("Theme Selector", root.themePickerComp) } }
        ]
      },
      {
        id: "snippets",
        title: "Snippets & Text Expansion",
        subtitle: "Manage dynamic text expansion templates",
        icon: "⚡",
        category: "Productivity",
        badge: "Built-in",
        action: function() { root.requestPushView("Snippets", root.snippetsComp) },
        actions: [
          { title: "Open Snippet Manager", icon: "⚡", shortcut: "↵", callback: function() { root.requestPushView("Snippets", root.snippetsComp) } }
        ]
      },
      {
        id: "window",
        title: "Window Management",
        subtitle: "Tile windows, move workspaces, split monitors (Hyprland)",
        icon: "🪟",
        category: "System",
        badge: "Hyprland",
        action: function() { root.requestPushView("Window Management", root.windowTilerComp) },
        actions: [
          { title: "Open Window Actions", icon: "🪟", shortcut: "↵", callback: function() { root.requestPushView("Window Management", root.windowTilerComp) } }
        ]
      },
      {
        id: "ai",
        title: "Ask AI Assistant",
        subtitle: "Query LLM, summarize text, or generate code",
        icon: "🤖",
        category: "Intelligence",
        badge: "AI",
        action: function() { root.requestPushView("Ask AI Assistant", root.aiAssistComp) },
        actions: [
          { title: "Open AI Assistant", icon: "🤖", shortcut: "↵", callback: function() { root.requestPushView("Ask AI Assistant", root.aiAssistComp) } }
        ]
      }
    ]

    // Section: OMARCHY COMMANDS
    if (omarchyCommands.length > 0) {
      items.push({ section: "OMARCHY SYSTEM COMMANDS", isHeader: true, title: "OMARCHY SYSTEM COMMANDS" })
      for (var oc = 0; oc < omarchyCommands.length; oc++) {
        items.push(omarchyCommands[oc])
      }
    }

    // Section: SCRIPT COMMANDS
    if (scriptCommands.length > 0) {
      items.push({ section: "SCRIPT COMMANDS", isHeader: true, title: "SCRIPT COMMANDS" })
      for (var k = 0; k < scriptCommands.length; k++) {
        items.push(scriptCommands[k])
      }
    }

    // Section: APPLICATIONS
    if (desktopApps.length > 0) {
      items.push({ section: "APPLICATIONS", isHeader: true, title: "APPLICATIONS" })
      for (var m = 0; m < desktopApps.length; m++) {
        items.push(desktopApps[m])
      }
    }

    allItems = items
    filter(filterText)
  }

  function filter(query) {
    root.filterText = query
    var results = []

    var mathResult = tryMathEvaluation(query)
    if (mathResult !== null) {
      results.push({ section: "CALCULATOR", isHeader: true, title: "CALCULATOR" })
      results.push({
        id: "calc-result",
        title: "= " + mathResult,
        subtitle: "Calculation result • Press ↵ to copy",
        icon: "🔢",
        category: "Calculator",
        badge: "Math",
        action: function() {
          Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "wl-copy \'' + mathResult + '\'"]; running: true }', root)
          root.requestDismiss()
        },
        actions: [
          { title: "Copy Result to Clipboard", icon: "📋", shortcut: "↵", callback: function() {
            Qt.createQmlObject('import Quickshell.Io; Process { command: ["sh", "-c", "wl-copy \'' + mathResult + '\'"]; running: true }', root)
            root.requestDismiss()
          }}
        ]
      })
    }

    if (!query || query.trim() === "") {
      filteredItems = allItems
    } else {
      var q = query.toLowerCase()
      var currentSection = null
      var hasItemsInSection = false

      for (var i = 0; i < allItems.length; i++) {
        var item = allItems[i]
        if (item.isHeader) {
          currentSection = item
          hasItemsInSection = false
          continue
        }

        var match = item.title.toLowerCase().includes(q) ||
                    (item.subtitle && item.subtitle.toLowerCase().includes(q)) ||
                    (item.category && item.category.toLowerCase().includes(q))

        if (match) {
          if (currentSection && !hasItemsInSection) {
            results.push(currentSection)
            hasItemsInSection = true
          }
          results.push(item)
        }
      }
      filteredItems = results
    }

    findNextSelectable(0, 1)
  }

  function findNextSelectable(start, direction) {
    if (filteredItems.length === 0) {
      selectedIndex = 0
      return
    }
    var idx = start
    while (idx >= 0 && idx < filteredItems.length) {
      if (!filteredItems[idx].isHeader) {
        selectedIndex = idx
        return
      }
      idx += direction
    }
    selectedIndex = Math.max(0, Math.min(start, filteredItems.length - 1))
  }

  function moveSelection(delta) {
    if (filteredItems.length === 0) return
    var next = selectedIndex + delta
    while (next >= 0 && next < filteredItems.length && filteredItems[next].isHeader) {
      next += delta
    }
    if (next >= 0 && next < filteredItems.length) {
      selectedIndex = next
      list.positionViewAtIndex(selectedIndex, ListView.Contain)
    }
  }

  function executeCurrent() {
    if (selectedItem && !selectedItem.isHeader && typeof selectedItem.action === "function") {
      selectedItem.action()
    }
  }

  function openActionPalette() {
    if (selectedItem && selectedItem.actions) {
      root.requestActionPalette(selectedItem.actions)
    }
  }

  ListView {
    id: list
    anchors.fill: parent
    anchors.margins: 8
    clip: true
    model: root.filteredItems
    boundsBehavior: Flickable.StopAtBounds

    delegate: ItemRow {
      width: list.width
      title: modelData.title
      subtitle: modelData.subtitle || ""
      iconText: modelData.icon || ""
      badgeText: modelData.badge || ""
      shortcutHint: modelData.shortcut || ""
      isSectionHeader: modelData.isHeader || false
      isSelected: index === root.selectedIndex

      onClicked: {
        root.selectedIndex = index
        root.executeCurrent()
      }
    }
  }

  EmptyState {
    visible: root.filteredItems.length === 0
    title: "No Matching Commands"
    subtitle: "No apps or commands match '" + root.filterText + "'"
  }

  Component.onCompleted: {
    scriptScanner.running = true
    appScanner.running = true
    omarchyScanner.running = true
  }
}
