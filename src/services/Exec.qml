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

  function hypr(dispatchArgs) {
    var argv = ["hyprctl", "dispatch"]
    for (var i = 0; i < dispatchArgs.length; i++)
      argv.push(String(dispatchArgs[i]))
    detached(argv)
  }

  function openUrl(url) {
    detached(["xdg-open", url])
  }

  function launchApp(execLine) {
    var cleaned = (execLine || "").replace(/%[fFuUdDnNickvm]/g, "").replace(/\s+/g, " ").trim()
    if (!cleaned.length)
      return
    detached(["sh", "-c", cleaned + " &"])
  }

  function launchInTerminal(cmd) {
    detached([root.terminal, "-e", "bash", "-c", cmd + '; echo; read -p "Press enter to close..."'])
  }

  function omarchyThemeSet(name) {
    detached(["omarchy", "theme", "set", name])
  }

  // --- Omarchy native surfaces (umbrella handoffs) ---

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

  // route e.g. "root", "style.theme", "style.background"
  function omarchyMenu(route) {
    detached(["omarchy-menu", "summon", route || "root"])
  }

  function omarchyThemePicker() {
    omarchyMenu("style.theme")
  }

  function omarchyBackgroundPicker() {
    omarchyMenu("style.background")
  }
}
