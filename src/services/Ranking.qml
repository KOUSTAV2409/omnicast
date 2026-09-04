pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
  id: root

  property var favorites: []
  property var aliases: ({})
  property var scores: ({})
  property var recent: []
  property bool loaded: false

  property Process loader: Process {
    command: ["python3", Paths.py("ranking.py"), "dump"]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => root._applyDump(text)
    }
  }

  function reload() {
    loader.running = true
  }

  function _applyDump(raw) {
    try {
      var data = JSON.parse(raw || "{}")
      favorites = data.favorites || []
      aliases = data.aliases || {}
      scores = data.scores || {}
      recent = data.recent || []
      loaded = true
    } catch (e) {
      console.error("[Ranking] parse error", e)
    }
  }

  function bump(itemId) {
    if (!itemId)
      return
    Exec.python("ranking.py", ["bump", itemId])
    // Optimistic local bump
    var entry = scores[itemId] || { count: 0, score: 0 }
    entry.count = (entry.count || 0) + 1
    entry.score = entry.count * 10 + Math.min(entry.count, 50)
    scores[itemId] = entry
    var r = recent.slice()
    var idx = r.indexOf(itemId)
    if (idx >= 0)
      r.splice(idx, 1)
    r.unshift(itemId)
    recent = r.slice(0, 40)
  }

  function toggleFavorite(itemId) {
    if (!itemId)
      return
    Exec.python("ranking.py", ["favorite", itemId])
    var f = favorites.slice()
    var i = f.indexOf(itemId)
    if (i >= 0)
      f.splice(i, 1)
    else
      f.unshift(itemId)
    favorites = f
  }

  function isFavorite(itemId) {
    return favorites.indexOf(itemId) >= 0
  }

  function setAlias(alias, itemId) {
    Exec.python("ranking.py", ["alias", alias, itemId])
    var a = Object.assign({}, aliases)
    a[String(alias).toLowerCase()] = itemId
    aliases = a
  }

  function aliasTarget(query) {
    if (!query)
      return ""
    return aliases[String(query).toLowerCase().trim()] || ""
  }

  function frecencyBoost(itemId) {
    var e = scores[itemId]
    if (!e)
      return 0
    return e.score || 0
  }

  Component.onCompleted: reload()
}
