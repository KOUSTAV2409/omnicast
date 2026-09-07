pragma Singleton
import QtQuick
import Quickshell

QtObject {
  id: root

  readonly property string terminal: {
    var t = Quickshell.env("TERMINAL") || ""
    if (t.length > 0)
      return t
    return "ghostty"
  }

  readonly property string pictures: {
    var p = Quickshell.env("XDG_PICTURES_DIR") || ""
    if (p.length)
      return p
    return (Quickshell.env("HOME") || "") + "/Pictures"
  }

  function detached(argv) {
    if (!argv || argv.length === 0)
      return
    try {
      Quickshell.execDetached(argv)
    } catch (e) {
      console.error("[Exec] detached failed:", e, argv)
    }
  }

  function python(scriptName, args) {
    var argv = ["python3", Paths.py(scriptName)]
    if (args && args.length) {
      for (var i = 0; i < args.length; i++)
        argv.push(String(args[i]))
    }
    detached(argv)
  }

  function copyText(text) {
    detached(["python3", Paths.py("util_io.py"), "copy", text || ""])
  }

  function copyFile(path) {
    detached(["python3", Paths.py("util_io.py"), "copy-file", path || ""])
  }

  function pasteText(text) {
    detached(["python3", Paths.py("util_io.py"), "paste", text || ""])
  }

  function pasteImage(path) {
    detached(["python3", Paths.py("util_io.py"), "paste-image", path || ""])
  }

  function hyprLua(expr) {
    if (!expr || !String(expr).length)
      return
    detached(["hyprctl", "dispatch", String(expr)])
  }

  function hypr(dispatchArgs) {
    var argv = ["hyprctl", "dispatch"]
    for (var i = 0; i < dispatchArgs.length; i++)
      argv.push(String(dispatchArgs[i]))
    detached(argv)
  }

  // Delayed argv run without shell — uses sleep(1) as argv[0] then the real command.
  // Prefer fixed argv arrays only; never pass user-controlled shell strings.
  function afterDismiss(argv, delayMs) {
    if (!argv || !argv.length)
      return
    var ms = delayMs === undefined ? 80 : delayMs
    var secs = Math.max(0, ms / 1000)
    // sleep then exec via env — still no user string concatenation into sh -c
    var wrapped = ["sleep", String(secs)]
    // Chain with a tiny helper: python -c is avoided; use `sh -c` ONLY with
    // individually single-quoted argv pieces (no raw user shell).
    var parts = []
    for (var i = 0; i < argv.length; i++)
      parts.push("'" + String(argv[i]).replace(/'/g, "'\\''") + "'")
    detached(["sh", "-c", "sleep " + secs + "; exec " + parts.join(" ")])
  }

  function openUrl(url) {
    var u = String(url || "")
    var low = u.toLowerCase()
    if (!(low.indexOf("https://") === 0 || low.indexOf("http://") === 0 || low.indexOf("mailto:") === 0)) {
      console.error("[Exec] blocked non-http(s)/mailto URL:", u)
      return
    }
    detached(["xdg-open", u])
  }

  function openPath(path) {
    if (!path || !String(path).length)
      return
    detached(["xdg-open", String(path)])
  }

  function openArgv(argv) {
    if (!argv || !argv.length)
      return
    detached(argv)
  }

  function revealPath(path) {
    if (!path || !String(path).length)
      return
    var p = String(path).replace(/\/$/, "")
    var slash = p.lastIndexOf("/")
    var parent = slash > 0 ? p.substring(0, slash) : "/"
    detached(["xdg-open", parent])
  }

  // Launch a .desktop app without shell. Prefer gtk-launch / gio / argv.
  function launchDesktop(desktopId, desktopPath, argv, terminal) {
    if (desktopId && String(desktopId).length) {
      detached(["gtk-launch", String(desktopId)])
      return
    }
    if (desktopPath && String(desktopPath).length) {
      detached(["gio", "launch", String(desktopPath)])
      return
    }
    if (argv && argv.length) {
      if (terminal)
        launchArgvInTerminal(argv)
      else
        detached(argv)
      return
    }
  }

  // Legacy: execLine may still arrive from old cache — refuse shell metacharacters.
  function launchApp(execLine) {
    var cleaned = (execLine || "").replace(/%[fFuUdDnNickvm]/g, "").replace(/\s+/g, " ").trim()
    if (!cleaned.length)
      return
    if (/[;&|`$<>\n]/.test(cleaned)) {
      console.error("[Exec] blocked unsafe Exec line (use desktop_path/argv):", cleaned)
      return
    }
    // Split on spaces only — no shell. Imperfect for quoted args; prefer launchDesktop.
    var parts = cleaned.split(/\s+/).filter(function(p) { return p.length })
    if (!parts.length)
      return
    detached(parts)
  }

  function launchArgvInTerminal(argv) {
    if (!argv || !argv.length)
      return
    var cmd = [root.terminal, "-e"].concat(argv)
    detached(cmd)
  }

  function launchInTerminal(cmd) {
    // Legacy string path — refuse metacharacters; prefer launchArgvInTerminal
    var c = String(cmd || "").trim()
    if (!c.length)
      return
    if (/[;&|`$<>\n]/.test(c)) {
      console.error("[Exec] blocked unsafe terminal command")
      return
    }
    var parts = c.split(/\s+/).filter(function(p) { return p.length })
    if (!parts.length)
      return
    launchArgvInTerminal(parts)
  }

  function omarchyThemeSet(name) {
    detached(["omarchy", "theme", "set", name])
  }

  function omarchyClipboard() {
    detached(["omarchy-menu-clipboard"])
  }

  function omarchyEmoji() {
    detached(["omarchy-menu-emoji"])
  }

  function omarchyKeybindings() {
    detached(["omarchy-menu-keybindings"])
  }

  function omarchyImages() {
    detached(["omarchy-menu-images", "--filterable", root.pictures])
  }

  function omarchyMenu(route) {
    // route is a fixed Omarchy menu id — reject shell metacharacters
    var r = String(route || "root")
    if (!/^[A-Za-z0-9._-]+$/.test(r)) {
      console.error("[Exec] blocked unsafe omarchy menu route:", r)
      return
    }
    detached(["omarchy-menu", "summon", r])
  }

  function omarchyThemePicker() {
    omarchyMenu("style.theme")
  }

  function omarchyBackgroundPicker() {
    omarchyMenu("style.background")
  }

  function omarchyFileOpen() {
    var opener = Paths.projectRoot + "/bin/omnicast-open-file"
    detached([opener])
  }

  // Run an Omarchy CLI route without shell when possible.
  function omarchyRoute(route) {
    var r = String(route || "").trim()
    if (!r.length)
      return
    if (/[;&|`$<>\n]/.test(r)) {
      console.error("[Exec] blocked unsafe omarchy route:", r)
      return
    }
    // Prefer bare argv when route looks like `omarchy …`
    if (r.indexOf("omarchy ") === 0 || r === "omarchy") {
      var parts = r.split(/\s+/).filter(function(p) { return p.length })
      detached(parts)
      return
    }
    if (r.indexOf("omarchy-") === 0 && r.indexOf(" ") < 0) {
      detached([r])
      return
    }
    // Last resort: only allow simple tokens (no shell ops already checked)
    var toks = r.split(/\s+/).filter(function(p) { return p.length })
    if (toks.length)
      detached(toks)
  }
}
