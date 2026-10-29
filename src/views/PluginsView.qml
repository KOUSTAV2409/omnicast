import QtQuick
import Quickshell
import Quickshell.Io
import "../services"
import "../components"

// Omarchy plugin directory: search the community catalog, hand off to the
// listing, and run enable/install through `omarchy plugin` (never a shell string).
Item {
  id: root

  property var navStack: null
  property string filterText: ""
  property int selectedIndex: 0
  property var allPlugins: []
  property var filteredItems: []
  property bool wideLayout: true
  property bool isLoading: scanner.running

  readonly property string searchPlaceholder: "Search Omarchy plugins…"
  readonly property string statusHint: {
    if (isLoading)
      return "Loading plugins…"
    if (!filterText.trim().length)
      return "Installed · type to search the directory"
    return filteredItems.length + " plugins"
  }
  readonly property var selectedItem: filteredItems.length > 0 && selectedIndex < filteredItems.length
                                      ? filteredItems[selectedIndex] : null

  signal requestActionPalette(var actions)
  signal requestDismiss()

  Process {
    id: scanner
    command: ["python3", Paths.py("plugin_catalog.py"), "scan"]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => root.loadCache(text)
    }
  }

  FileView {
    id: cacheFile
    path: Paths.cacheFile("plugins.json")
    blockLoading: true
    printErrors: false
  }

  function onOps(_ok, _op, _id, _message) {
    scanner.running = true
  }

  function reload() {
    scanner.running = true
  }

  function loadCache(_raw) {
    cacheFile.path = ""
    cacheFile.path = Paths.cacheFile("plugins.json")
    var text = ""
    try { text = cacheFile.text() || "" } catch (e) { text = "" }
    var plugins = []
    try {
      var data = JSON.parse(text || "{}")
      if (Array.isArray(data))
        plugins = data
      else if (data && Array.isArray(data.plugins))
        plugins = data.plugins
    } catch (e2) {
      plugins = []
    }
    allPlugins = plugins
    filter(filterText)
  }

  function listingUrl(id) {
    if (!/^[A-Za-z0-9][A-Za-z0-9._-]*$/.test(id || ""))
      return ""
    return "https://omarchyplugins.com/plugin.html?id=" + encodeURIComponent(id)
  }

  function openListing(id) {
    var url = listingUrl(id)
    if (!url.length) {
      Hud.error("Invalid plugin id")
      return
    }
    root.requestDismiss()
    Exec.openUrl(url)
  }

  function openRepo(url) {
    var u = String(url || "")
    if (u.indexOf("https://") !== 0) {
      Hud.error("No repository URL")
      return
    }
    root.requestDismiss()
    Exec.openUrl(u)
  }

  function detailText(p) {
    var lines = []
    lines.push(p.description || p.subtitle || "")
    lines.push("")
    lines.push("id: " + (p.id || ""))
    if (p.author) lines.push("author: " + p.author)
    if (p.category) lines.push("category: " + p.category)
    if (p.kind) lines.push("kind: " + p.kind)
    if (p.version) lines.push("version: " + p.version)
    if (p.installed)
      lines.push("state: " + (p.enabled ? "installed, enabled" : "installed, disabled"))
    else
      lines.push("state: not installed")
    lines.push("")
    lines.push("Enter opens the Omarchy Plugins listing. Install runs omarchy plugin add.")
    return lines.join("\n")
  }

  function makeItem(p) {
    var id = p.id || ""
    var installed = !!p.installed
    var enabled = !!p.enabled
    var canToggle = installed && p.canDisable !== false
    var primary = "Open Listing"
    if (installed && !enabled && canToggle)
      primary = "Enable"
    var item = {
      id: "plugin-" + id,
      title: p.title || id,
      subtitle: p.subtitle || p.description || id,
      icon: installed ? "󰏖" : "󰏗",
      badge: installed ? (enabled ? "On" : "Off") : "Store",
      keyword: id,
      category: "Plugins",
      primaryActionTitle: primary,
      detail: root.detailText(p),
      actions: []
    }
    item.action = function() {
      if (installed && !enabled && canToggle)
        PluginOps.run("enable", id)
      else
        root.openListing(id)
    }
    var acts = [
      { title: primary, icon: "↵", shortcut: "↵", callback: item.action },
      { title: "Open Listing", icon: "󰖟", callback: function() { root.openListing(id) } }
    ]
    if (p.repo)
      acts.push({ title: "Open Repository", icon: "󰊤", callback: function() { root.openRepo(p.repo) } })
    if (!installed && p.installable)
      acts.push({ title: "Install and Enable", icon: "󰏗", callback: function() { PluginOps.run("install", id) } })
    if (canToggle && enabled)
      acts.push({ title: "Disable", icon: "󰒭", callback: function() { PluginOps.run("disable", id) } })
    if (installed && !p.firstParty && p.canDisable !== false)
      acts.push({ title: "Remove", icon: "󰆴", callback: function() { PluginOps.run("remove", id) } })
    item.actions = acts
    return item
  }

  function filter(query) {
    root.filterText = query || ""
    var q = root.filterText.trim()
    var pool = []
    if (!q.length) {
      for (var i = 0; i < allPlugins.length; i++) {
        if (allPlugins[i].installed)
          pool.push(allPlugins[i])
      }
      pool.sort(function(a, b) {
        if (!!a.enabled !== !!b.enabled) return a.enabled ? -1 : 1
        if (!!a.firstParty !== !!b.firstParty) return a.firstParty ? 1 : -1
        return String(a.title || "").localeCompare(String(b.title || ""))
      })
    } else {
      var scored = []
      var ql = q.toLowerCase()
      for (var j = 0; j < allPlugins.length; j++) {
        var p = allPlugins[j]
        var blob = ((p.title || "") + " " + (p.id || "") + " " + (p.tags || "") + " " + (p.subtitle || "") + " " + (p.description || "")).toLowerCase()
        if (blob.indexOf(ql) < 0)
          continue
        var probe = {
          title: p.title, subtitle: p.subtitle || p.description || "",
          category: p.category || "Plugins", keyword: p.id, badge: p.tags || ""
        }
        var s = Fuzzy.itemScore(q, probe)
        if (s < 120) continue
        if (p.installed) s += 40
        scored.push({ p: p, score: s })
      }
      scored.sort(function(a, b) { return b.score - a.score })
      var cap = Math.min(scored.length, 80)
      for (var k = 0; k < cap; k++)
        pool.push(scored[k].p)
    }
    var items = []
    for (var n = 0; n < pool.length; n++)
      items.push(makeItem(pool[n]))
    filteredItems = items
    selectedIndex = items.length ? 0 : 0
  }

  function moveSelection(delta) {
    if (!filteredItems.length) return
    var next = selectedIndex + delta
    if (next < 0) next = filteredItems.length - 1
    if (next >= filteredItems.length) next = 0
    selectedIndex = next
    list.positionViewAtIndex(selectedIndex, ListView.Contain)
  }

  function executeCurrent() {
    if (selectedItem && typeof selectedItem.action === "function")
      selectedItem.action()
  }

  function openActionPalette() {
    if (selectedItem && selectedItem.actions)
      root.requestActionPalette(selectedItem.actions)
  }

  Row {
    anchors.fill: parent

    ListView {
      id: list
      width: Math.round(parent.width * 0.46)
      height: parent.height
      clip: true
      model: root.filteredItems
      spacing: Theme.rowSpacing
      boundsBehavior: Flickable.StopAtBounds

      delegate: ItemRow {
        width: list.width
        title: modelData.title
        subtitle: modelData.subtitle || ""
        iconText: modelData.icon || ""
        badgeText: modelData.badge || ""
        isSelected: index === root.selectedIndex
        onClicked: root.selectedIndex = index
        onDoubleClicked: { root.selectedIndex = index; root.executeCurrent() }
      }
    }

    Rectangle {
      width: 1
      height: parent.height
      color: Theme.border
    }

    DetailPane {
      width: parent.width - list.width - 1
      height: parent.height
      title: root.selectedItem ? root.selectedItem.title : "Plugins"
      headerBadge: root.selectedItem ? (root.selectedItem.badge || "") : ""
      contentFormat: "plain"
      markdownContent: {
        if (root.isLoading && !root.allPlugins.length)
          return "Loading the Omarchy plugin directory…"
        if (root.selectedItem)
          return root.selectedItem.detail || ""
        if (!root.filterText.trim().length)
          return "Installed plugins are listed here. Type to search omarchyplugins.com."
        return "No plugins matched."
      }
    }
  }

  Component.onCompleted: {
    PluginOps.finished.connect(root.onOps)
    reload()
  }

  Component.onDestruction: {
    PluginOps.finished.disconnect(root.onOps)
  }
}
