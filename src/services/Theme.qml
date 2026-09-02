pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
  id: root

  property string home: Quickshell.env("HOME")
  property string colorsPath: home + "/.local/state/omarchy/current/theme/colors.toml"

  // Base theme palette tokens (defaults to Eventide dark palette)
  property color background: "#141b24"
  property color darkBackground: "#0e131b"
  property color darkerBackground: "#090d13"
  property color lighterBackground: "#1b2532"
  
  // Solid, high-contrast modal background to prevent background text bleed
  property color cardBackground: Qt.rgba(0.07, 0.09, 0.13, 0.98)
  property color itemHoverBackground: Qt.rgba(1.0, 1.0, 1.0, 0.06)
  property color itemSelectedBackground: Qt.rgba(0.98, 0.52, 0.15, 0.18)

  property color foreground: "#d8d4d0"
  property color lightForeground: "#e6e2de"
  property color brightForeground: "#ffffff"
  property color darkForeground: "#6d7c8d"
  property color muted: "#828d9c"
  property color accent: "#fa8526"
  property color selection: "#283548"
  property color border: Qt.rgba(1.0, 1.0, 1.0, 0.12)
  property color subtleBorder: Qt.rgba(1.0, 1.0, 1.0, 0.06)

  // Typography
  property string fontFamily: "Inter, 'Noto Sans', sans-serif"
  property string monoFontFamily: "'JetBrains Mono', 'Fira Code', monospace"

  // Geometry
  property int windowRadius: 16
  property int itemRadius: 8
  property int badgeRadius: 4

  // Process to read and parse colors.toml
  property Process colorWatcher: Process {
    command: ["cat", root.colorsPath]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => root.parseColors(text)
    }
  }

  // Periodic check for external theme changes
  property Timer themeCheckTimer: Timer {
    interval: 3000
    repeat: true
    running: true
    onTriggered: root.reloadTheme()
  }

  function reloadTheme() {
    if (!colorWatcher.running) {
      colorWatcher.running = true
    }
  }

  function parseColors(raw) {
    if (!raw) return
    var lines = raw.split("\n")
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim()
      if (!line || line.startsWith("#") || !line.includes("=")) continue
      var parts = line.split("=")
      var key = parts[0].trim()
      var val = parts[1].trim().replace(/['"]/g, "")

      if (key === "background") root.background = val
      else if (key === "dark_background") root.darkBackground = val
      else if (key === "darker_background") root.darkerBackground = val
      else if (key === "lighter_background") root.lighterBackground = val
      else if (key === "foreground") root.foreground = val
      else if (key === "dark_foreground") root.darkForeground = val
      else if (key === "light_foreground") root.lightForeground = val
      else if (key === "bright_foreground") root.brightForeground = val
      else if (key === "accent" || key === "orange") {
        root.accent = val
        root.itemSelectedBackground = Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.20)
      }
      else if (key === "muted") root.muted = val
      else if (key === "selection") root.selection = val
    }
  }

  Component.onCompleted: {
    reloadTheme()
  }
}
