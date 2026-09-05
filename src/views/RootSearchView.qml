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
  property var quickLinkItems: []
  property var fileHits: []
  property string fileQuery: ""
  property var itemById: ({})

  property bool isLoading: scriptScanner.running || omarchyScanner.running
                              || appScanner.running || quicklinkScanner.running
  property bool filesSearching: fileScanner.running || fileSearchDebounce.running || fileSearchStartTimer.running

  signal requestActionPalette(var actions)
  signal requestPushView(string title, var component)
  signal requestPushViewWithProps(string title, var component, var props)
  signal requestDismiss()

  readonly property var selectedItem: filteredItems.length > 0 && selectedIndex < filteredItems.length
                                      ? filteredItems[selectedIndex] : null

  property Component windowTilerComp: Component { WindowTilerView {} }
  property Component snippetsComp: Component { SnippetsView {} }
  property Component aiAssistComp: Component { AiAssistView {} }
  property Component scriptResultComp: Component { ScriptResultView {} }
  property Component formViewComp: Component { FormView {} }
  property Component filePreviewComp: Component { FilePreviewView {} }

  Process {
    id: scriptScanner
    command: ["python3", Paths.py("script_runner.py"), "scan"]
    running: false
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: text => root.handleScriptScanMeta(text) }
  }
  Process {
    id: omarchyScanner
    command: ["python3", Paths.py("omarchy_commands.py")]
    running: false
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: text => root.handleOmarchyScanMeta(text) }
  }

  FileView {
    id: omarchyCacheFile
    path: Paths.cacheFile("omarchy-commands.json")
    blockLoading: true
    printErrors: true
  }
  Process {
    id: appScanner
    command: ["python3", Paths.py("app_indexer.py")]
    running: false
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: text => root.handleAppScanMeta(text) }
  }

  FileView {
    id: appsCacheFile
    path: Paths.cacheFile("desktop-apps.json")
    blockLoading: true
    printErrors: true
  }
  Process {
    id: quicklinkScanner
    command: ["python3", Paths.py("quicklinks.py"), "list"]
    running: false
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: text => root.handleQuicklinkScanMeta(text) }
  }

  Process {
    id: fileScanner
    property string pendingQuery: ""
    // Bind query into argv (SnippetsView insertProc pattern)
    command: ["python3", Paths.py("file_search.py"), pendingQuery, "--limit", "16"]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => root.handleFileScanMeta(fileScanner.pendingQuery, text)
    }
  }

  FileView {
    id: fileSearchCacheFile
    path: Paths.cacheFile("file-search.json")
    blockLoading: true
    printErrors: false
  }

  Timer {
    id: fileSearchDebounce
    interval: 100
    repeat: false
    onTriggered: root.runFileSearch(root.filterText)
  }

  Timer {
    id: fileSearchStartTimer
    interval: 1
    repeat: false
    onTriggered: {
      if (fileScanner.pendingQuery.length >= 2)
        fileScanner.running = true
    }
  }

  FileView {
    id: scriptsCacheFile
    path: Paths.cacheFile("script-commands.json")
    blockLoading: true
    printErrors: true
  }
  FileView {
    id: quicklinksCacheFile
    path: Paths.cacheFile("quicklinks.json")
    blockLoading: true
    printErrors: true
  }

  Connections {
    target: Ranking
    function onFavoritesChanged() { root.buildFullItemList() }
    function onRecentChanged() { root.buildFullItemList() }
  }

  function header(title) { return { section: title, isHeader: true, title: title } }

  function withMetaActions(item, primaryActions) {
    var acts = (primaryActions || []).slice()
    if (!item || !item.id || item.isHeader) return acts
    var fav = Ranking.isFavorite(item.id)
    acts.push({
      title: fav ? "Remove Favorite" : "Add Favorite",
      icon: fav ? "★" : "☆",
      callback: function() {
        Ranking.toggleFavorite(item.id)
        Hud.success(fav ? "Removed from Favorites" : "Added to Favorites")
        root.buildFullItemList()
      }
    })
    return acts
  }

  function pushTool(id, title, subtitle, icon, badge, category, primary, comp, pushTitle) {
    var item = {
      id: id, title: title, subtitle: subtitle, icon: icon, badge: badge,
      category: category, primaryActionTitle: primary, actions: []
    }
    item.action = function() {
      Ranking.bump(id)
      if (comp)
        root.requestPushView(pushTitle || title, comp)
      else
        root.filter("quicklink")
    }
    item.actions = withMetaActions(item, [
      { title: primary, icon: icon, shortcut: "↵", callback: item.action }
    ])
    return item
  }

  // Dismiss Omnicast then open a native Omarchy surface (exclusive focus).
  function handoff(id, launchFn) {
    Ranking.bump(id)
    root.requestDismiss()
    launchFn()
  }

  function handoffTool(id, title, subtitle, icon, badge, category, primary, launchFn) {
    var item = {
      id: id, title: title, subtitle: subtitle, icon: icon, badge: badge,
      category: category, primaryActionTitle: primary, actions: []
    }
    item.action = function() { root.handoff(id, launchFn) }
    item.actions = withMetaActions(item, [
      { title: primary, icon: icon, shortcut: "↵", callback: item.action }
    ])
    return item
  }

  function omarchyHandoffs() {
    return [
      handoffTool("clipboard", "Clipboard History", "Super+Ctrl+V",
                  "", "Omarchy", "Omarchy", "Open Clipboard",
                  function() { Exec.omarchyClipboard() }),
      handoffTool("emoji", "Emoji", "Super+Ctrl+E",
                  "", "Omarchy", "Omarchy", "Open Emoji",
                  function() { Exec.omarchyEmoji() }),
      handoffTool("theme", "Theme", "Switch Omarchy theme",
                  "󰸌", "Omarchy", "Omarchy", "Open Themes",
                  function() { Exec.omarchyThemePicker() }),
      handoffTool("background", "Background", "Wallpaper",
                  "", "Omarchy", "Omarchy", "Open Backgrounds",
                  function() { Exec.omarchyBackgroundPicker() }),
      handoffTool("images", "Images", "Browse Pictures",
                  "󰋫", "Omarchy", "Omarchy", "Open Images",
                  function() { Exec.omarchyImages() }),
      handoffTool("files", "Find Files", "Portal picker (typed search is below)",
                  "󰈔", "Omarchy", "Omarchy", "Open Files",
                  function() { Exec.omarchyFileOpen() }),
      handoffTool("keybindings", "Keybindings", "Super+K",
                  "", "Omarchy", "Omarchy", "Open Keybindings",
                  function() { Exec.omarchyKeybindings() }),
      handoffTool("omarchy-menu", "Menu", "Super+Space",
                  "󰣇", "Omarchy", "Omarchy", "Open Menu",
                  function() { Exec.omarchyMenu("root") }),
      handoffTool("capture", "Capture", "Screenshot & record",
                  "", "Omarchy", "Omarchy", "Open Capture",
                  function() { Exec.omarchyMenu("capture") }),
      handoffTool("share", "Share", "Clipboard, file, folder",
                  "", "Omarchy", "Omarchy", "Open Share",
                  function() { Exec.omarchyMenu("share") }),
      handoffTool("reminders", "Reminders", "Super+Ctrl+R",
                  "󰢻", "Omarchy", "Omarchy", "Open Reminders",
                  function() { Exec.omarchyMenu("reminder-set") })
    ]
  }

  function omnicastTools() {
    return [
      pushTool("snippets", "Snippets", "Text expansion",
               "󰅍", "Omnicast", "Omnicast", "Open Snippets", root.snippetsComp, "Snippets"),
      pushTool("window", "Windows", "Pop · float · gaps · Omarchy hypr",
               "󰖯", "Omnicast", "Omnicast", "Window Management", root.windowTilerComp, "Window Management"),
      pushTool("ai", "Ask AI", "Local / BYOK",
               "󰚩", "Omnicast", "Omnicast", "Ask AI", root.aiAssistComp, "Ask AI"),
      pushTool("quicklinks-mgr", "Quicklinks", "URL bookmarks",
               "󰌷", "Omnicast", "Omnicast", "Quicklinks", null, "")
    ]
  }

  function powerTools() {
    return omarchyHandoffs().concat(omnicastTools())
  }

  function makeOmarchyItem(c) {
    var route = c.route || ""
    var item = {
      id: c.id, title: c.title, subtitle: c.subtitle || ("Execute " + route),
      icon: c.icon || "⚙️", category: c.category || "Omarchy", badge: "Omarchy",
      route: route, keyword: route, primaryActionTitle: "Run", actions: []
    }
    item.action = function() {
      Ranking.bump(item.id)
      Exec.detached(["sh", "-c", item.route + " &"])
      Hud.success("Ran " + item.title)
      root.requestDismiss()
    }
    item.actions = withMetaActions(item, [
      { title: "Run Command", icon: "⚡", shortcut: "↵", callback: item.action },
      { title: "Run in Terminal", icon: "", callback: function() {
        Ranking.bump(item.id)
        Exec.launchInTerminal(item.route)
        Hud.success("Opened in terminal")
        root.requestDismiss()
      }}
    ])
    return item
  }

  function makeAppItem(a) {
    var item = {
      id: a.id, title: a.title, subtitle: a.subtitle || "Application",
      icon: a.icon || "", category: "Applications", badge: "App",
      exec: a.exec, desktopPath: a.desktop_path, primaryActionTitle: "Open", actions: []
    }
    item.action = function() {
      Ranking.bump(item.id)
      Exec.launchApp(item.exec)
      Hud.success("Launched " + item.title)
      root.requestDismiss()
    }
    item.actions = withMetaActions(item, [
      { title: "Launch Application", icon: "🚀", shortcut: "↵", callback: item.action },
      { title: "Launch in Terminal", icon: "", callback: function() {
        Ranking.bump(item.id)
        Exec.launchInTerminal(item.exec || "")
        Hud.success("Launched in terminal")
        root.requestDismiss()
      }}
    ])
    return item
  }

  function makeScriptItem(s) {
    var item = {
      id: s.id, title: s.title, subtitle: s.subtitle || "Script Command",
      icon: s.icon || "⚡", category: s.category || "Script Commands", badge: "Script",
      path: s.path, mode: s.mode || "fullOutput", arguments: s.arguments || [],
      primaryActionTitle: "Run Script", actions: []
    }
    item.action = function() { root.runScriptCommand(item) }
    item.actions = withMetaActions(item, [
      { title: "Run Script", icon: "⚡", shortcut: "↵", callback: item.action }
    ])
    return item
  }

  function makeQuicklinkItem(q) {
    var item = {
      id: q.id, title: q.title, subtitle: q.subtitle || q.url || "Quicklink",
      icon: q.icon || "🔗", category: "Quicklinks", badge: "Link",
      url: q.url, keyword: q.keyword || "", needsArgument: !!q.needsArgument,
      primaryActionTitle: q.primaryActionTitle || "Open Link", actions: []
    }
    item.action = function() { root.openQuicklink(item) }
    item.actions = withMetaActions(item, [
      { title: "Open Link", icon: "🔗", shortcut: "↵", callback: item.action }
    ])
    return item
  }

  function makeFileItem(f) {
    var path = f.path || ""
    var item = {
      id: f.id, title: f.title || f.name || path, subtitle: f.subtitle || path,
      icon: f.icon || "󰈔", category: "Files", badge: f.badge || (f.is_dir ? "Dir" : "File"),
      path: path, isDir: !!f.is_dir, keyword: path,
      primaryActionTitle: "Preview", actions: []
    }
    item.action = function() {
      Ranking.bump(item.id)
      root.requestPushViewWithProps(item.title, root.filePreviewComp, {
        filePath: item.path,
        fileTitle: item.title
      })
    }
    item.actions = withMetaActions(item, [
      { title: "Preview", icon: "󰈈", shortcut: "↵", callback: item.action },
      { title: "Open Externally", icon: "󰏌", callback: function() {
        Ranking.bump(item.id)
        root.requestDismiss()
        Exec.openPath(item.path)
        Hud.success("Opened " + item.title)
      }},
      { title: "Copy Path", icon: "", callback: function() {
        Exec.copyText(item.path)
        Hud.success("Copied path")
      }},
      { title: "Reveal", icon: "󰉋", callback: function() {
        Ranking.bump(item.id)
        root.requestDismiss()
        if (item.isDir)
          Exec.openPath(item.path)
        else
          Exec.revealPath(item.path)
      }}
    ])
    return item
  }

  function runFileSearch(query) {
    var q = (query || "").trim()
    if (q.length < 2) {
      fileHits = []
      fileQuery = ""
      fileScanner.pendingQuery = ""
      fileScanner.running = false
      fileSearchStartTimer.stop()
      return
    }
    if (fileScanner.running && fileScanner.pendingQuery === q)
      return
    fileScanner.running = false
    fileScanner.pendingQuery = q
    console.log("[Omnicast] file search start:", q)
    // Defer restart so Quickshell Process fully stops before relaunch
    fileSearchStartTimer.restart()
  }

  function scheduleFileSearch(query) {
    var q = (query || "").trim()
    if (q.length < 2) {
      fileSearchDebounce.stop()
      fileSearchStartTimer.stop()
      fileHits = []
      fileQuery = ""
      fileScanner.pendingQuery = ""
      fileScanner.running = false
      return
    }
    // Already have results for this query, or search already queued/running
    if (fileQuery === q)
      return
    if (fileScanner.pendingQuery === q && (fileScanner.running || fileSearchDebounce.running || fileSearchStartTimer.running))
      return
    fileSearchDebounce.restart()
  }

  function handleFileScanMeta(query, raw) {
    var q = (query || "").trim()
    console.log("[Omnicast] file search meta:", q, (raw || "").trim().slice(0, 120))
    // Ignore stale responses when the user kept typing
    if (q !== (root.filterText || "").trim())
      return

    var hits = []
    try {
      // Prefer cache file (reliable); fall back to inline JSON list if present
      fileSearchCacheFile.path = ""
      fileSearchCacheFile.path = Paths.cacheFile("file-search.json")
      var cached = ""
      try { cached = fileSearchCacheFile.text() || "" } catch (e0) {}
      var data = null
      if (cached.length) {
        var payload = JSON.parse(cached)
        if (payload && payload.query === q && payload.hits)
          data = payload.hits
      }
      if (!data) {
        var meta = JSON.parse((raw || "").trim() || "{}")
        if (meta && meta.hits)
          data = meta.hits
        else if (Array.isArray(meta))
          data = meta
      }
      if (data && data.length) {
        for (var i = 0; i < data.length; i++)
          hits.push(makeFileItem(data[i]))
      }
    } catch (e) {
      console.error("[Omnicast] file search parse failed:", e, raw)
    }
    fileQuery = q
    fileHits = hits
    console.log("[Omnicast] file search hits:", hits.length, "for", q)
    root.filter(root.filterText)
  }

  function handleOmarchyScanMeta(raw) {
    // Python prints a tiny {ok,count,path} status; payload is in the cache file
    // (StdioCollector drops ~100KB+ stdout, so we FileView the cache instead).
    try {
      var meta = JSON.parse((raw || "").trim() || "{}")
      console.log("[Omnicast] omarchy scan meta:", meta.count, meta.path || "")
    } catch (e) {
      console.error("[Omnicast] omarchy scan meta parse failed:", e, raw)
    }
    // Force reload after writer finished
    omarchyCacheFile.path = ""
    omarchyCacheFile.path = Paths.cacheFile("omarchy-commands.json")
    var text = ""
    try {
      text = omarchyCacheFile.text() || ""
    } catch (e2) {
      console.error("[Omnicast] omarchy cache read failed:", e2)
    }
    root.handleOmarchyScan(text)
  }

  function handleOmarchyScan(raw) {
    try {
      var cmds = JSON.parse(raw || "[]")
      if (!Array.isArray(cmds))
        cmds = []
      var list = []
      for (var i = 0; i < cmds.length; i++) list.push(makeOmarchyItem(cmds[i]))
      omarchyCommands = list
      console.log("[Omnicast] omarchy commands indexed:", list.length)
    } catch (e) {
      console.error("Error parsing Omarchy commands:", e)
      omarchyCommands = []
    }
    buildFullItemList()
  }

  function handleAppScanMeta(raw) {
    try {
      var meta = JSON.parse((raw || "").trim() || "{}")
      console.log("[Omnicast] app scan meta:", meta.count, meta.path || "")
    } catch (e) {
      console.error("[Omnicast] app scan meta parse failed:", e, raw)
    }
    appsCacheFile.path = ""
    appsCacheFile.path = Paths.cacheFile("desktop-apps.json")
    var text = ""
    try {
      text = appsCacheFile.text() || ""
    } catch (e2) {
      console.error("[Omnicast] apps cache read failed:", e2)
    }
    root.handleAppScan(text)
  }

  function handleAppScan(raw) {
    try {
      var apps = JSON.parse(raw || "[]")
      if (!Array.isArray(apps))
        apps = []
      var list = []
      for (var i = 0; i < apps.length; i++) list.push(makeAppItem(apps[i]))
      desktopApps = list
      console.log("[Omnicast] apps indexed:", list.length)
    } catch (e) {
      console.error("Error parsing app indexer output:", e)
      desktopApps = []
    }
    buildFullItemList()
  }

  function handleScriptScanMeta(raw) {
    scriptsCacheFile.path = ""
    scriptsCacheFile.path = Paths.cacheFile("script-commands.json")
    var text = ""
    try { text = scriptsCacheFile.text() || "" } catch (e) {
      console.error("[Omnicast] scripts cache read failed:", e)
    }
    root.handleScriptScan(text)
  }

  function handleQuicklinkScanMeta(raw) {
    quicklinksCacheFile.path = ""
    quicklinksCacheFile.path = Paths.cacheFile("quicklinks.json")
    var text = ""
    try { text = quicklinksCacheFile.text() || "" } catch (e) {
      console.error("[Omnicast] quicklinks cache read failed:", e)
    }
    root.handleQuicklinkScan(text)
  }

  function handleScriptScan(raw) {
    try {
      var scripts = JSON.parse(raw || "[]")
      if (!Array.isArray(scripts))
        scripts = []
      var list = []
      for (var i = 0; i < scripts.length; i++) list.push(makeScriptItem(scripts[i]))
      scriptCommands = list
      console.log("[Omnicast] scripts indexed:", list.length)
    } catch (e) {
      console.error("Error parsing script scanner output:", e)
      scriptCommands = []
    }
    buildFullItemList()
  }

  function handleQuicklinkScan(raw) {
    try {
      var links = JSON.parse(raw || "[]")
      if (!Array.isArray(links))
        links = []
      var list = []
      for (var i = 0; i < links.length; i++) list.push(makeQuicklinkItem(links[i]))
      quickLinkItems = list
      console.log("[Omnicast] quicklinks indexed:", list.length)
    } catch (e) {
      console.error("Error parsing quicklinks:", e)
      quickLinkItems = []
    }
    buildFullItemList()
  }

  function quicklinkArgFromQuery(item) {
    var q = (filterText || "").trim()
    if (!q.length) return ""
    var kw = (item.keyword || "").toLowerCase()
    var lower = q.toLowerCase()
    if (kw.length && (lower === kw || lower.startsWith(kw + " ")))
      return q.substring(kw.length).trim()
    var sp = q.indexOf(" ")
    return sp > 0 ? q.substring(sp + 1).trim() : ""
  }

  function openQuicklink(item) {
    var arg = quicklinkArgFromQuery(item)
    if (item.needsArgument && !arg.length) {
      root.requestPushViewWithProps(item.title + " (Argument)", root.formViewComp, {
        title: item.title,
        subtitle: "Provide the link argument.",
        fields: [{ id: "arg", label: "ARGUMENT", type: "text", placeholder: "Search or path…" }],
        onFormSubmitted: function(values) {
          Ranking.bump(item.id)
          Exec.python("quicklinks.py", ["open", item.id, (values && values.arg) ? String(values.arg) : ""])
          Hud.success("Opened " + item.title)
          root.requestDismiss()
        }
      })
      return
    }
    Ranking.bump(item.id)
    Exec.python("quicklinks.py", ["open", item.id, arg])
    Hud.success("Opened " + item.title)
    root.requestDismiss()
  }

  function runScriptCommand(s, presetArgs) {
    var args = presetArgs || []
    if ((!presetArgs || !presetArgs.length) && s.arguments && s.arguments.length > 0) {
      var formFields = []
      for (var j = 0; j < s.arguments.length; j++) {
        var a = s.arguments[j]
        formFields.push({
          id: a.name || ("arg" + (j + 1)),
          label: a.name ? String(a.name).toUpperCase() : ("Argument " + (j + 1)),
          type: a.type || "text",
          placeholder: a.placeholder || "Enter value..."
        })
      }
      root.requestPushViewWithProps(s.title + " (Inputs)", root.formViewComp, {
        title: s.title,
        subtitle: "Provide required arguments to execute script.",
        fields: formFields,
        onFormSubmitted: function(values) {
          var argsList = []
          for (var k = 0; k < formFields.length; k++)
            argsList.push(values[formFields[k].id] || "")
          root.finishScript(s, argsList)
        }
      })
      return
    }
    finishScript(s, args)
  }

  function finishScript(s, argsList) {
    Ranking.bump(s.id)
    var mode = (s.mode || "fullOutput").toLowerCase()
    if (mode === "silent" || mode === "compact") {
      var argv = ["exec", s.path]
      for (var i = 0; i < (argsList || []).length; i++)
        argv.push(String(argsList[i]))
      Exec.python("script_runner.py", argv)
      Hud.success(mode === "silent" ? ("Ran " + s.title) : (s.title + " finished"))
      root.requestDismiss()
      return
    }
    root.requestPushViewWithProps(s.title, root.scriptResultComp, {
      scriptTitle: s.title, scriptPath: s.path, scriptArgs: argsList || []
    })
  }

  function tryMathEvaluation(query) {
    if (!query) return null
    var clean = query.trim()
    if (!/^[0-9.\s+\-*/()%^eE]+$/.test(clean) || !/[0-9]/.test(clean) || !/[+\-*/%^]/.test(clean))
      return null
    try {
      var result = Function('"use strict"; return (' + clean.replace(/\^/g, "**") + ')')()
      if (typeof result === "number" && isFinite(result))
        return Number.isInteger(result) ? result.toLocaleString()
               : result.toFixed(6).replace(/\.?0+$/, "")
    } catch (e) {}
    return null
  }

  function tryColorEvaluation(query) {
    if (!query) return null
    var clean = query.trim()
    var m = clean.match(/^#([0-9a-fA-F]{6}|[0-9a-fA-F]{3})$/)
    if (m) {
      var hex = m[1]
      if (hex.length === 3)
        hex = hex[0] + hex[0] + hex[1] + hex[1] + hex[2] + hex[2]
      hex = "#" + hex.toUpperCase()
      return { hex: hex, label: "Color " + hex }
    }
    m = clean.match(/^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})(?:\s*,\s*[\d.]+)?\s*\)$/i)
    if (!m) return null
    var r = Math.min(255, parseInt(m[1], 10)), g = Math.min(255, parseInt(m[2], 10)), b = Math.min(255, parseInt(m[3], 10))
    var h = "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1).toUpperCase()
    return { hex: h, label: "Color " + h + "  ·  rgb(" + r + ", " + g + ", " + b + ")" }
  }

  function tryUnitConversion(query) {
    if (!query) return null
    var m = query.trim().match(/^(-?[\d.]+)\s*(km|mi|m|ft|kg|lb|lbs|c|f|°c|°f)\s+to\s+(km|mi|m|ft|kg|lb|lbs|c|f|°c|°f)$/i)
    if (!m) return null
    var n = parseFloat(m[1])
    if (!isFinite(n)) return null
    var from = m[2].toLowerCase().replace("°", "").replace("lbs", "lb")
    var to = m[3].toLowerCase().replace("°", "").replace("lbs", "lb")
    var factors = { "km:mi": 0.621371, "mi:km": 1.60934, "m:ft": 3.28084, "ft:m": 0.3048, "kg:lb": 2.20462, "lb:kg": 0.453592 }
    var out = null
    if (factors[from + ":" + to] !== undefined) out = n * factors[from + ":" + to]
    else if (from === "c" && to === "f") out = n * 9 / 5 + 32
    else if (from === "f" && to === "c") out = (n - 32) * 5 / 9
    else if (from === to) out = n
    if (out === null || !isFinite(out)) return null
    return (Math.abs(out) >= 100 ? out.toFixed(2) : out.toFixed(4)).replace(/\.?0+$/, "") + " " + to
  }

  // Rough offline FX vs USD: always treat as a guess; prefer Google for live rates.
  function tryCurrencyConversion(query) {
    if (!query) return null
    var m = query.trim().match(/^(-?[\d.]+)\s*(usd|eur|gbp|inr|jpy|aud|cad|\$|€|£|₹)\s*(?:to|in)\s*(usd|eur|gbp|inr|jpy|aud|cad|\$|€|£|₹)$/i)
    if (!m) return null
    var n = parseFloat(m[1])
    if (!isFinite(n)) return null
    function norm(c) {
      c = String(c).toLowerCase()
      if (c === "$") return "usd"
      if (c === "€") return "eur"
      if (c === "£") return "gbp"
      if (c === "₹") return "inr"
      return c
    }
    var from = norm(m[2]), to = norm(m[3])
    // Ballpark only (stale). Do not use for real money.
    var usd = { usd: 1, eur: 0.86, gbp: 0.74, inr: 94.4, jpy: 148.0, aud: 1.48, cad: 1.36 }
    if (usd[from] === undefined || usd[to] === undefined) return null
    if (from === to)
      return null
    var out = n * (usd[to] / usd[from])
    var rounded = (Math.abs(out) >= 100 ? out.toFixed(2) : out.toFixed(4)).replace(/\.?0+$/, "")
    var googleQ = n + " " + from.toUpperCase() + " to " + to.toUpperCase()
    return {
      approx: "≈ " + rounded + " " + to.toUpperCase() + " ?",
      copyValue: rounded + " " + to.toUpperCase(),
      googleQuery: googleQ
    }
  }

  function fxGoogleRow(googleQuery) {
    var q = googleQuery
    var item = {
      id: "calc-fx-google", title: "Search Google for live rate",
      subtitle: "Recommended: offline FX is a rough guess only",
      icon: "󰍉", badge: "", category: "Calculator",
      primaryActionTitle: "Search", actions: []
    }
    item.action = function() {
      Ranking.bump("calc-fx-google")
      root.requestDismiss()
      Exec.openUrl("https://www.google.com/search?q=" + encodeURIComponent(q))
    }
    item.actions = [{ title: "Search Google", icon: "󰍉", shortcut: "↵", callback: item.action }]
    return item
  }

  function tryDateEvaluation(query) {
    if (!query) return null
    var q = query.trim().toLowerCase()
    var now = new Date()
    function fmt(d) {
      var y = d.getFullYear()
      var m = ("" + (d.getMonth() + 1))
      var day = ("" + d.getDate())
      if (m.length < 2) m = "0" + m
      if (day.length < 2) day = "0" + day
      return y + "-" + m + "-" + day
    }
    function parseYmd(s) {
      var p = s.match(/^(\d{4})-(\d{2})-(\d{2})$/)
      if (!p) return null
      var d = new Date(parseInt(p[1], 10), parseInt(p[2], 10) - 1, parseInt(p[3], 10))
      return isNaN(d.getTime()) ? null : d
    }
    if (q === "today") return fmt(now)
    if (q === "now") {
      var hh = ("" + now.getHours())
      var mm = ("" + now.getMinutes())
      if (hh.length < 2) hh = "0" + hh
      if (mm.length < 2) mm = "0" + mm
      return fmt(now) + " " + hh + ":" + mm
    }
    var m = q.match(/^days\s+(until|since)\s+(\d{4}-\d{2}-\d{2})$/)
    if (m) {
      var target = parseYmd(m[2])
      if (!target) return null
      var start = new Date(now.getFullYear(), now.getMonth(), now.getDate())
      var diff = Math.round((target - start) / 86400000)
      if (m[1] === "since") diff = -diff
      return String(diff) + " day" + (Math.abs(diff) === 1 ? "" : "s")
    }
    m = q.match(/^(\d{4}-\d{2}-\d{2})\s*([+-])\s*(\d+)\s*days?$/)
    if (m) {
      var base = parseYmd(m[1])
      if (!base) return null
      var delta = parseInt(m[3], 10) * (m[2] === "-" ? -1 : 1)
      base.setDate(base.getDate() + delta)
      return fmt(base)
    }
    return null
  }

  function calcRow(id, title, subtitle, copyValue) {
    var item = {
      id: id, title: title, subtitle: subtitle, icon: "🔢",
      category: "Calculator", badge: "Calc", primaryActionTitle: "Copy", actions: []
    }
    item.action = function() {
      Exec.copyText(copyValue)
      Hud.success("Copied " + copyValue)
      root.requestDismiss()
    }
    item.actions = [{ title: "Copy to Clipboard", icon: "📋", shortcut: "↵", callback: item.action }]
    return item
  }

  function registerItems(map, items) {
    for (var i = 0; i < items.length; i++) {
      if (items[i] && items[i].id && !items[i].isHeader)
        map[items[i].id] = items[i]
    }
  }

  function itemsFromIds(ids, map, seen) {
    var out = []
    for (var i = 0; i < (ids || []).length; i++) {
      var id = ids[i]
      if (seen[id] || !map[id]) continue
      seen[id] = true
      out.push(map[id])
    }
    return out
  }

  function appendSection(dest, title, items) {
    if (!items || !items.length) return
    dest.push(header(title))
    for (var i = 0; i < items.length; i++) dest.push(items[i])
  }

  function catalogItems() {
    return powerTools().concat(quickLinkItems, omarchyCommands, scriptCommands, desktopApps, windowCatalog())
  }

  // Root-indexed Omarchy window helpers only (no classic hyprctl batches :
  // those break on Lua Hyprland and left windows floating/overlapping).
  function windowCatalog() {
    function wrap(id, title, subtitle, icon, run) {
      var item = {
        id: id, title: title, subtitle: subtitle, icon: icon,
        badge: "", category: "Windows", primaryActionTitle: title, actions: []
      }
      item.action = run
      item.actions = [{ title: title, icon: icon, shortcut: "↵", callback: run }]
      return item
    }
    function oma(id, title, subtitle, icon, argv) {
      return wrap(id, title, subtitle, icon, function() {
        Ranking.bump(id)
        root.requestDismiss()
        Exec.afterDismiss(argv, 80)
        Hud.success(title)
      })
    }
    function lua(id, title, subtitle, icon, expr) {
      return wrap(id, title, subtitle, icon, function() {
        Ranking.bump(id)
        root.requestDismiss()
        Exec.afterDismiss(["hyprctl", "dispatch", expr], 80)
        Hud.success(title)
      })
    }
    return [
      oma("om-pop", "Pop Window", "Super+O · float & pin (toggle)", "󰖯",
          ["omarchy-hyprland-window-pop"]),
      oma("om-gaps", "Toggle Gaps", "No gaps ↔ default", "󰝘",
          ["omarchy-hyprland-window-gaps-toggle"]),
      oma("om-trans", "Toggle Transparency", "Active window opacity", "󰗔",
          ["omarchy-hyprland-window-transparency-toggle"]),
      oma("om-tfs", "Tiled Fullscreen", "Borderless tiled fullscreen", "󰊓",
          ["omarchy-hyprland-window-tiled-fullscreen-toggle"]),
      lua("win-float", "Toggle Float", "Super+T · tile ↔ float", "󰖲",
          "hl.dsp.window.float({ action = \"toggle\" })"),
      lua("win-full", "Fullscreen", "Super+F", "󰊓",
          "hl.dsp.window.fullscreen({ mode = \"fullscreen\" })")
    ]
  }

  function fallbackItems(query) {
    var q = query
    var web = {
      id: "fallback-web", title: "Search Web", subtitle: "Google · " + q,
      icon: "󰍉", badge: "", category: "Fallback", primaryActionTitle: "Search", actions: []
    }
    web.action = function() {
      Ranking.bump("fallback-web")
      root.requestDismiss()
      Exec.openUrl("https://www.google.com/search?q=" + encodeURIComponent(q))
    }
    web.actions = [{ title: "Search Web", icon: "󰍉", shortcut: "↵", callback: web.action }]

    var ai = {
      id: "fallback-ai", title: "Ask AI", subtitle: q,
      icon: "󰚩", badge: "", category: "Fallback", primaryActionTitle: "Ask", actions: []
    }
    ai.action = function() {
      Ranking.bump("fallback-ai")
      root.requestPushViewWithProps("Ask AI", root.aiAssistComp, {})
    }
    ai.actions = [{ title: "Ask AI", icon: "󰚩", shortcut: "↵", callback: ai.action }]
    return [web, ai]
  }

  function buildFullItemList() {
    var tools = powerTools()
    var wins = windowCatalog()
    var map = ({})
    registerItems(map, tools)
    registerItems(map, wins)
    registerItems(map, quickLinkItems)
    registerItems(map, omarchyCommands)
    registerItems(map, scriptCommands)
    registerItems(map, desktopApps)
    itemById = map

    var items = [], seen = ({})
    appendSection(items, "Favorites", itemsFromIds(Ranking.favorites, map, seen))
    appendSection(items, "Recent", itemsFromIds(Ranking.recent, map, seen))
    appendSection(items, "Omarchy", omarchyHandoffs())
    appendSection(items, "Omnicast", omnicastTools())
    appendSection(items, "Quicklinks", quickLinkItems)
    appendSection(items, "Commands", omarchyCommands)
    appendSection(items, "Scripts", scriptCommands)
    appendSection(items, "Applications", desktopApps)
    allItems = items
    filter(filterText)
  }

  function filter(query) {
    root.filterText = query
    var results = []
    var q = (query || "").trim()

    var mathResult = tryMathEvaluation(q)
    if (mathResult !== null) {
      results.push(header("Calculator"))
      results.push(calcRow("calc-result", "= " + mathResult, "↵ to copy", String(mathResult)))
    }
    var colorResult = tryColorEvaluation(q)
    if (colorResult) {
      if (!results.length) results.push(header("Calculator"))
      results.push(calcRow("calc-color", colorResult.label, "↵ to copy hex", colorResult.hex))
    }
    var unitResult = tryUnitConversion(q)
    if (unitResult) {
      if (!results.length) results.push(header("Calculator"))
      results.push(calcRow("calc-unit", "= " + unitResult, "↵ to copy", unitResult))
    }
    var fxResult = tryCurrencyConversion(q)
    if (fxResult) {
      if (!results.length) results.push(header("Calculator"))
      results.push(calcRow("calc-fx", fxResult.approx,
                           "⚠️ stale offline guess: prefer Google", fxResult.copyValue))
      results.push(fxGoogleRow(fxResult.googleQuery))
    }
    var dateResult = tryDateEvaluation(q)
    if (dateResult) {
      if (!results.length) results.push(header("Calculator"))
      results.push(calcRow("calc-date", dateResult, "date · ↵ to copy", dateResult))
    }

    if (!q.length) {
      fileSearchDebounce.stop()
      fileHits = []
      fileQuery = ""
      fileScanner.running = false
      filteredItems = results.length ? results.concat(allItems) : allItems
      findNextSelectable(0, 1)
      return
    }

    // Kick async file search (fd/plocate under $HOME)
    scheduleFileSearch(q)

    var aliasId = Ranking.aliasTarget(q)
    var scored = [], catalog = catalogItems()
    for (var i = 0; i < catalog.length; i++) {
      var item = catalog[i]
      var fuzzy = Fuzzy.itemScore(q, item)
      // Drop weak / sparse subsequence noise
      if (fuzzy < 120 && !(aliasId && aliasId === item.id)) continue
      scored.push({
        item: item,
        score: (aliasId && aliasId === item.id ? 100000 : 0) + Ranking.frecencyBoost(item.id) + fuzzy
      })
    }
    scored.sort(function(a, b) { return b.score - a.score })
    if (scored.length) {
      results.push(header("Results"))
      for (var s = 0; s < scored.length; s++) results.push(scored[s].item)
    }

    // Files section: show hits for this exact query
    if (fileQuery === q && fileHits.length) {
      results.push(header("Files"))
      for (var fi = 0; fi < fileHits.length; fi++) results.push(fileHits[fi])
    } else if (q.length >= 2 && filesSearching) {
      results.push(header("Files"))
      results.push({
        id: "loading-files", title: "Searching files…", subtitle: "fd · " + q,
        icon: "⏳", badge: "", category: "Files", isHeader: false,
        primaryActionTitle: "", actions: [], action: function() {}
      })
    }

    if (!scored.length && !(fileQuery === q && fileHits.length)) {
      if (root.isLoading || (q.length >= 2 && filesSearching)) {
        // Still indexing catalogs or files: don't falsely fall back to web/AI
        if (!results.length || (results.length && results[results.length - 1].id !== "loading-files")) {
          // Keep loading-files row if present; else show catalog loading
          if (!(q.length >= 2 && filesSearching)) {
            results.push(header("Loading"))
            results.push({
              id: "loading-catalog", title: "Indexing commands…", subtitle: "Try again in a moment",
              icon: "⏳", badge: "", category: "System", isHeader: false,
              primaryActionTitle: "", actions: [], action: function() {}
            })
          }
        }
      } else {
        results.push(header("Fallback"))
        var fb = fallbackItems(q)
        for (var f = 0; f < fb.length; f++) results.push(fb[f])
      }
    }
    filteredItems = results
    findNextSelectable(0, 1)
  }

  function findNextSelectable(start, direction) {
    if (!filteredItems.length) { selectedIndex = 0; return }
    var idx = start
    while (idx >= 0 && idx < filteredItems.length) {
      if (!filteredItems[idx].isHeader) { selectedIndex = idx; return }
      idx += direction
    }
    selectedIndex = Math.max(0, Math.min(start, filteredItems.length - 1))
  }

  function moveSelection(delta) {
    if (!filteredItems.length) return
    var next = selectedIndex + delta
    while (next >= 0 && next < filteredItems.length && filteredItems[next].isHeader)
      next += delta
    if (next >= 0 && next < filteredItems.length) {
      selectedIndex = next
      list.positionViewAtIndex(selectedIndex, ListView.Contain)
    }
  }

  function executeCurrent() {
    if (selectedItem && !selectedItem.isHeader && typeof selectedItem.action === "function")
      selectedItem.action()
  }

  function openActionPalette() {
    if (!selectedItem || selectedItem.isHeader) return
    var acts = selectedItem.actions
    if (!acts || !acts.length) {
      acts = withMetaActions(selectedItem, [
        { title: selectedItem.primaryActionTitle || "Select", icon: "↵", shortcut: "↵",
          callback: function() { root.executeCurrent() } }
      ])
    }
    root.requestActionPalette(acts)
  }

  ListView {
    id: list
    anchors.fill: parent
    clip: true
    model: root.filteredItems
    boundsBehavior: Flickable.StopAtBounds
    spacing: Theme.rowSpacing

    delegate: ItemRow {
      width: list.width
      title: modelData.title
      subtitle: modelData.subtitle || ""
      iconText: modelData.icon || ""
      badgeText: modelData.badge || ""
      shortcutHint: modelData.shortcut || ""
      isSectionHeader: modelData.isHeader || false
      isSelected: index === root.selectedIndex
      onClicked: { root.selectedIndex = index; root.executeCurrent() }
    }
  }

  EmptyState {
    visible: !root.isLoading && root.filteredItems.length === 0
    title: "No Matching Commands"
    subtitle: "No apps or commands match '" + root.filterText + "'"
  }

  Component.onCompleted: {
    buildFullItemList()
    scriptScanner.running = true
    appScanner.running = true
    omarchyScanner.running = true
    quicklinkScanner.running = true
  }
}
