pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Omnicast visual tokens: prefer Omarchy [launcher] / [menu] from shell.toml
// so the umbrella matches clipboard / menu / emoji surfaces.
QtObject {
  id: root

  property string home: Quickshell.env("HOME")
  property string themeDir: home + "/.local/state/omarchy/current/theme"
  property string colorsPath: themeDir + "/colors.toml"
  property string shellTomlPath: themeDir + "/shell.toml"

  // Foundational palette (colors.toml)
  property color background: "#141b24"
  property color darkBackground: "#0e131b"
  property color darkerBackground: "#090d13"
  property color lighterBackground: "#1b2532"
  property color foreground: "#d8d4d0"
  property color lightForeground: "#e6e2de"
  property color brightForeground: "#f5f0ec"
  property color darkForeground: "#6d7c8d"
  property color muted: "#4c5c72"
  property color accent: "#fa8526"
  property color selection: "#283548"
  property color urgent: "#e06553"

  // Launcher / menu surface (shell.toml [launcher] then [menu])
  property color cardBackground: "#141b24"
  property color scrim: Qt.rgba(0.08, 0.11, 0.14, 0.50)
  property color border: Qt.rgba(0.85, 0.83, 0.82, 0.35)
  property color subtleBorder: Qt.rgba(0.85, 0.83, 0.82, 0.12)
  property color itemHoverBackground: Qt.rgba(0.85, 0.83, 0.82, 0.06)
  property color itemSelectedBackground: Qt.rgba(0.85, 0.83, 0.82, 0.08)
  property color itemSelectedText: "#fa8526"
  property color itemSelectedBorder: Qt.rgba(0.85, 0.83, 0.82, 0.25)

  property string fontFamily: "monospace"
  property string monoFontFamily: "monospace"
  // Readable body font for doc/markdown previews (UI stays on fontFamily/mono)
  property string proseFontFamily: "Noto Sans"


  // Type scale: mirrors Omarchy Style.font (base 12)
  property int fontCaption: 10
  property int fontBodySmall: 11
  property int fontBody: 12
  property int fontHeading: 16
  property int fontIcon: 18

  // Geometry: Omarchy menu/clipboard language
  property int windowRadius: 0
  property int itemRadius: 0
  property int badgeRadius: 0
  property int cardWidth: 480
  property int cardHeight: 560
  property int panelPadding: 18
  property int contentSpacing: 12
  property int rowHeight: 44
  property int sectionHeight: 22
  property int headerHeight: 36
  property int footerHeight: 28
  property int iconSlot: 36
  property int gapsOut: 5
  property int rowSpacing: 4

  property var _shellValues: ({})

  property Process colorWatcher: Process {
    command: ["cat", root.colorsPath]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => root.parseColors(text)
    }
  }

  property Process shellTomlWatcher: Process {
    command: ["cat", root.shellTomlPath]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => root.parseShellToml(text)
    }
  }

  property Process fontResolver: Process {
    command: ["fc-match", "-f", "%{family[0]}", "monospace"]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => {
        var override = Quickshell.env("OMARCHY_MENU_FONT") || ""
        var fam = override.length ? override : (text || "").trim()
        if (fam.length) {
          root.fontFamily = fam
          root.monoFontFamily = fam
        }
      }
    }
  }

  property Process proseFontResolver: Process {
    command: ["fc-match", "-f", "%{family[0]}", "sans-serif"]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => {
        var fam = (text || "").trim()
        if (fam.length)
          root.proseFontFamily = fam
      }
    }
  }

  property Process hyprRounding: Process {
    command: ["hyprctl", "-j", "getoption", "decoration:rounding"]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => {
        try {
          var j = JSON.parse(text || "{}")
          var n = j.int !== undefined ? j.int : parseInt(j.str || "0", 10)
          if (isFinite(n)) {
            root.windowRadius = Math.max(0, n)
            root.itemRadius = Math.max(0, n)
          }
        } catch (e) {}
      }
    }
  }

  property Timer themeCheckTimer: Timer {
    interval: 2500
    repeat: true
    running: true
    onTriggered: root.reloadTheme()
  }

  function withAlpha(c, a) {
    return Qt.rgba(c.r, c.g, c.b, Math.max(0, Math.min(1, a)))
  }

  function parseHex(val, fallback) {
    var s = String(val || "").trim().replace(/['"]/g, "")
    if (s.indexOf("hyprland.") === 0 || s.indexOf("gradient") >= 0)
      return fallback
    if (s.charAt(0) === "#" && (s.length === 7 || s.length === 9))
      return s
    if (s === "foreground" || s === "text") return root.foreground
    if (s === "background") return root.background
    if (s === "accent") return root.accent
    if (s === "muted") return root.muted
    if (s === "urgent") return root.urgent
    return fallback
  }

  function parseColors(raw) {
    if (!raw) return
    var lines = raw.split("\n")
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim()
      if (!line || line.startsWith("#") || line.indexOf("=") < 0) continue
      var parts = line.split("=")
      var key = parts[0].trim()
      var val = parts.slice(1).join("=").trim().replace(/['"]/g, "")
      if (key === "background") root.background = val
      else if (key === "dark_background") root.darkBackground = val
      else if (key === "darker_background") root.darkerBackground = val
      else if (key === "lighter_background") root.lighterBackground = val
      else if (key === "foreground") root.foreground = val
      else if (key === "dark_foreground") root.darkForeground = val
      else if (key === "light_foreground") root.lightForeground = val
      else if (key === "bright_foreground") root.brightForeground = val
      else if (key === "accent" || key === "orange") root.accent = val
      else if (key === "muted") root.muted = val
      else if (key === "selection") root.selection = val
      else if (key === "red") root.urgent = val
    }
    // Fallback card until shell.toml applies
    root.cardBackground = root.withAlpha(root.background, 0.98)
    root.applySurfaceFromShell()
  }

  function parseShellToml(raw) {
    var values = ({})
    var section = ""
    var lines = String(raw || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].replace(/#.*$/, "").trim()
      if (!line) continue
      var sec = line.match(/^\[([^\]]+)\]$/)
      if (sec) {
        section = sec[1]
        continue
      }
      var kv = line.match(/^([A-Za-z0-9_-]+)\s*=\s*(.+)$/)
      if (!kv || !section) continue
      var key = section + "." + kv[1]
      var val = kv[2].trim()
      if ((val.charAt(0) === '"' && val.charAt(val.length - 1) === '"')
          || (val.charAt(0) === "'" && val.charAt(val.length - 1) === "'"))
        val = val.substring(1, val.length - 1)
      values[key] = val
    }
    root._shellValues = values
    root.applySurfaceFromShell()
  }

  function shellGet(key, fallback) {
    var v = root._shellValues[key]
    return (typeof v === "string" && v.length) ? v : fallback
  }

  function shellNum(key, fallback) {
    var n = Number(shellGet(key, ""))
    return isFinite(n) ? n : fallback
  }

  // Prefer [menu] for opaque card surfaces (launcher.alpha is often 0.95 and bleeds).
  // Fall back to [launcher] only when menu lacks the field.
  function surfaceGet(field, fallback) {
    var m = shellGet("menu." + field, "")
    if (m.length) return m
    var a = shellGet("launcher." + field, "")
    if (a.length) return a
    return fallback
  }

  function surfaceNum(field, fallback) {
    var m = shellGet("menu." + field, "")
    if (m.length && isFinite(Number(m))) return Number(m)
    var a = shellGet("launcher." + field, "")
    if (a.length && isFinite(Number(a))) return Number(a)
    return fallback
  }

  function applySurfaceFromShell() {
    var bg = parseHex(surfaceGet("background", ""), root.background)
    // Never translucent enough for desktop text to bleed through
    var bgA = Math.max(0.98, surfaceNum("background-alpha", 1.0))
    root.cardBackground = root.withAlpha(bg, bgA)

    // Keep text hierarchy from colors.toml: only override body text from surface
    var text = parseHex(surfaceGet("text", ""), root.foreground)
    root.foreground = text

    var borderC = parseHex(surfaceGet("border", ""), root.foreground)
    var borderA = Math.min(0.55, Math.max(0.22, surfaceNum("border-alpha", 0.35)))
    root.border = root.withAlpha(borderC, borderA)
    root.subtleBorder = root.withAlpha(borderC, 0.10)

    var scrimC = parseHex(surfaceGet("scrim", ""), root.darkerBackground)
    var scrimA = Math.max(0.55, surfaceNum("scrim-alpha", 0.55))
    root.scrim = root.withAlpha(scrimC, scrimA)

    var selBg = parseHex(surfaceGet("selected-background", ""), root.foreground)
    var selBgA = surfaceNum("selected-background-alpha", 0.08)
    root.itemSelectedBackground = root.withAlpha(selBg, Math.max(0.10, selBgA))
    root.itemHoverBackground = root.withAlpha(selBg, 0.05)

    var selText = parseHex(surfaceGet("selected-text", ""), root.accent)
    root.itemSelectedText = selText
    // Don't overwrite colors.toml accent with selected-text every reload :
    // keep accent for pills; selected row uses itemSelectedText
    if (!root.accent || String(root.accent) === "#fa8526")
      root.accent = selText

    var selBorder = parseHex(surfaceGet("selected-border", ""), root.foreground)
    var selBorderA = surfaceNum("selected-border-alpha", 0.0)
    root.itemSelectedBorder = root.withAlpha(selBorder, selBorderA)
  }

  function reloadTheme() {
    if (!colorWatcher.running)
      colorWatcher.running = true
    if (!shellTomlWatcher.running)
      shellTomlWatcher.running = true
    if (!fontResolver.running)
      fontResolver.running = true
    if (!proseFontResolver.running)
      proseFontResolver.running = true
    if (!hyprRounding.running)
      hyprRounding.running = true
  }

  Component.onCompleted: reloadTheme()
}
