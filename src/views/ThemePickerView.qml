import QtQuick
import Quickshell
import Quickshell.Io
import "../services"
import "../components"

Item {
  id: root

  property var navStack: null
  property string filterText: ""

  signal requestActionPalette(var actions)
  signal requestDismiss()

  // Process to fetch available themes from `omarchy theme list`
  property Process themeScanner: Process {
    command: ["sh", "-c", "omarchy theme list 2>/dev/null"]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => root.loadThemes(text)
    }
  }

  function initDefaultThemes() {
    var defaultList = "Eventide\nNord\nCatppuccin\nTokyo Night\nGruvbox\nRose Pine\nKanagawa\nEverforest\nMatte Black\nHackerman\nSolarized Dark\nAether\nAegis Protocol"
    loadThemes(defaultList)
  }

  function loadThemes(raw) {
    if (!raw || raw.trim() === "") return
    var lines = raw.trim().split("\n")
    var themeItems = []

    var themePalettes = {
      "Eventide": { color: "#fa8526", bg: "#141b24", accent: "#fa8526", desc: "Deep twilight blues with sunset warm orange accents" },
      "Nord": { color: "#88c0d0", bg: "#2e3440", accent: "#88c0d0", desc: "An arctic, north-bluish clean color palette" },
      "Catppuccin": { color: "#cba6f7", bg: "#1e1e2e", accent: "#cba6f7", desc: "Soothing pastel palette for high-spirited focus" },
      "Catppuccin Latte": { color: "#8839ef", bg: "#eff1f5", accent: "#8839ef", desc: "Light version of Catppuccin with crisp accents" },
      "Tokyo Night": { color: "#7aa2f7", bg: "#1a1b26", accent: "#7aa2f7", desc: "A clean dark theme celebrating downtown Tokyo night lights" },
      "Gruvbox": { color: "#fe8019", bg: "#282828", accent: "#fe8019", desc: "Retro groove warm contrast colors" },
      "Rose Pine": { color: "#ebbcba", bg: "#191724", accent: "#ebbcba", desc: "All natural pine, faux fur and delicate lilac" },
      "Kanagawa": { color: "#7e9cd8", bg: "#1f1f28", accent: "#7e9cd8", desc: "Inspired by Katsushika Hokusai woodblock prints" },
      "Everforest": { color: "#a7c080", bg: "#2d353b", accent: "#a7c080", desc: "Comfortable natural green theme with medium contrast" },
      "Hackerman": { color: "#00ff66", bg: "#0d1117", accent: "#00ff66", desc: "High-contrast cyber matrix green palette" },
      "Matte Black": { color: "#ffffff", bg: "#000000", accent: "#888888", desc: "Monochrome pure black OLED theme" },
      "Solarized Dark": { color: "#268bd2", bg: "#002b36", accent: "#268bd2", desc: "Precision color scheme designed for prolonged screen work" }
    }

    for (var i = 0; i < lines.length; i++) {
      var name = lines[i].replace(/^\s*[\*•-]\s*/, "").trim()
      if (!name) continue
      var isCurrent = name.includes("(current)") || name === "Eventide"
      var cleanName = name.replace(/\s*\(current\)\s*/, "").trim()
      var p = themePalettes[cleanName] || { color: "#fa8526", bg: "#151820", accent: "#fa8526", desc: "Omarchy curated system theme" }

      themeItems.push({
        title: cleanName,
        subtitle: p.desc,
        color: p.color,
        badge: isCurrent ? "Active" : "Theme",
        icon: "🎨",
        markdown: "### Theme: " + cleanName + "\n\n" + p.desc + "\n\n**Primary Accent:** `" + p.accent + "`\n\n**Background Base:** `" + p.bg + "`\n\nApplies seamlessly across **Hyprland, Quickshell, Ghostty, Alacritty, Neovim, Starship, and GTK**.",
        metadata: [
          { label: "Accent Color", value: p.accent },
          { label: "Background", value: p.bg },
          { label: "Status", value: isCurrent ? "Currently Active" : "Available" }
        ],
        action: (function(themeName) {
          return function() {
            Qt.createQmlObject('import Quickshell.Io; Process { command: ["omarchy", "theme", "set", "' + themeName + '"]; running: true }', root)
            Theme.reloadTheme()
          }
        })(cleanName),
        actions: [
          {
            title: "Apply Theme (" + cleanName + ")",
            icon: "✨",
            shortcut: "↵",
            callback: (function(themeName) {
              return function() {
                Qt.createQmlObject('import Quickshell.Io; Process { command: ["omarchy", "theme", "set", "' + themeName + '"]; running: true }', root)
                Theme.reloadTheme()
              }
            })(cleanName)
          }
        ]
      })
    }

    listDetail.items = themeItems
    listDetail.filter(root.filterText)
  }

  function filter(query) {
    root.filterText = query
    listDetail.filter(query)
  }

  function moveSelection(delta) {
    listDetail.moveSelection(delta)
  }

  function executeCurrent() {
    listDetail.executeCurrent()
  }

  function openActionPalette() {
    listDetail.openActionPalette()
  }

  ListDetailView {
    id: listDetail
    anchors.fill: parent

    onRequestActionPalette: actions => root.requestActionPalette(actions)
  }

  Component.onCompleted: {
    initDefaultThemes()
    themeScanner.running = true
  }
}
