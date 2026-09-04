pragma Singleton
import QtQuick
import Quickshell

QtObject {
  id: root

  // Quickshell -p path (src/). Falls back to env for edge cases.
  readonly property string srcRoot: {
    var d = Quickshell.shellDir || ""
    if (d.length > 0)
      return d
    var env = Quickshell.env("OMNICAST_ROOT") || ""
    if (env.length > 0)
      return env + "/src"
    return Quickshell.env("HOME") + "/Projects/omnicast/src"
  }

  readonly property string backend: srcRoot + "/backend"
  readonly property string commands: srcRoot + "/commands"
  readonly property string projectRoot: {
    // src -> parent
    var parts = srcRoot.split("/")
    if (parts.length > 1)
      return parts.slice(0, parts.length - 1).join("/")
    return srcRoot
  }

  function py(scriptName) {
    return backend + "/" + scriptName
  }

  function cacheFile(name) {
    var home = Quickshell.env("HOME") || ""
    var xdg = Quickshell.env("XDG_CACHE_HOME") || ""
    var base = xdg.length ? xdg : (home + "/.cache")
    return base + "/omnicast/" + name
  }
}
