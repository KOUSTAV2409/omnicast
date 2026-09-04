import QtQuick
import Quickshell
import Quickshell.Io
import "../services"
import "../components"

Item {
  id: root

  property var navStack: null
  property string filterText: ""
  property var themeItems: []

  signal requestActionPalette(var actions)
  signal requestDismiss()

  readonly property var selectedItem: grid.selectedItem

  property Process themeScanner: Process {
    command: ["sh", "-c", "omarchy theme list 2>/dev/null; echo; omarchy theme current 2>/dev/null"]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => root.loadThemes(text)
    }
  }

  property string currentThemeName: ""

  function loadThemes(raw) {
    var lines = (raw || "").trim().split("\n")
    var current = ""
    var names = []
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].replace(/^\s*[\*•-]\s*/, "").trim()
      if (!line)
        continue
      if (line.toLowerCase().indexOf("current") >= 0 && names.length > 0 && line.indexOf("(") < 0) {
        // trailing "omarchy theme current" output
        current = line.replace(/\s*\(current\)\s*/i, "").trim()
        continue
      }
      if (line.includes("(current)")) {
        current = line.replace(/\s*\(current\)\s*/i, "").trim()
        names.push(current)
      } else {
        names.push(line)
      }
    }
    if (current)
      root.currentThemeName = current

    var themePalettes = {
      "Eventide": { color: "#fa8526", bg: "#141b24", desc: "Deep twilight blues with sunset warm orange accents" },
      "Nord": { color: "#88c0d0", bg: "#2e3440", desc: "Arctic north-bluish palette" },
      "Catppuccin": { color: "#cba6f7", bg: "#1e1e2e", desc: "Soothing pastel palette" },
      "Tokyo Night": { color: "#7aa2f7", bg: "#1a1b26", desc: "Downtown Tokyo night lights" },
      "Gruvbox": { color: "#fe8019", bg: "#282828", desc: "Retro groove warm contrast" },
      "Rose Pine": { color: "#ebbcba", bg: "#191724", desc: "Natural pine and lilac" },
      "Kanagawa": { color: "#7e9cd8", bg: "#1f1f28", desc: "Hokusai-inspired blues" },
      "Everforest": { color: "#a7c080", bg: "#2d353b", desc: "Comfortable natural green" },
      "Hackerman": { color: "#00ff66", bg: "#0d1117", desc: "Cyber matrix green" },
      "Matte Black": { color: "#ffffff", bg: "#000000", desc: "Monochrome OLED black" },
      "Solarized Dark": { color: "#268bd2", bg: "#002b36", desc: "Precision prolonged-screen scheme" }
    }

    if (names.length === 0) {
      names = Object.keys(themePalettes)
    }

    var items = []
    for (var j = 0; j < names.length; j++) {
      var cleanName = names[j].replace(/\s*\(current\)\s*/i, "").trim()
      if (!cleanName)
        continue
      var isCurrent = cleanName === root.currentThemeName
      var p = themePalettes[cleanName] || { color: "#fa8526", bg: "#151820", desc: "Omarchy curated system theme" }
      items.push({
        id: "theme-" + cleanName,
        title: cleanName,
        subtitle: p.desc,
        color: p.color,
        badge: isCurrent ? "Active" : "Theme",
        icon: "🎨",
        primaryActionTitle: "Apply Theme",
        category: "Appearance",
        markdown: "### Theme: " + cleanName + "\n\n" + p.desc + "\n\n**Accent:** `" + p.color + "`",
        metadata: [
          { label: "Accent", value: p.color },
          { label: "Background", value: p.bg },
          { label: "Status", value: isCurrent ? "Active" : "Available" }
        ],
        action: (function(themeName) {
          return function() { root.applyTheme(themeName) }
        })(cleanName),
        actions: [
          {
            title: "Apply Theme",
            icon: "✨",
            shortcut: "↵",
            callback: (function(themeName) {
              return function() { root.applyTheme(themeName) }
            })(cleanName)
          }
        ]
      })
    }
    themeItems = items
    grid.items = items
    grid.filter(filterText)
  }

  function applyTheme(name) {
    Exec.omarchyThemeSet(name)
    Theme.reloadTheme()
    currentThemeName = name
    Hud.success("Theme: " + name)
    root.requestDismiss()
  }

  function filter(query) {
    root.filterText = query
    grid.filter(query)
  }

  function moveSelection(delta) {
    // Grid: map vertical list moves to row steps
    if (delta > 0)
      grid.moveDown()
    else
      grid.moveUp()
  }

  function executeCurrent() {
    grid.executeCurrent()
  }

  function openActionPalette() {
    grid.openActionPalette()
  }

  GridView {
    id: grid
    anchors.fill: parent
    anchors.margins: 8
    onRequestActionPalette: actions => root.requestActionPalette(actions)
  }

  Component.onCompleted: {
    themeScanner.running = true
  }
}
