pragma Singleton
import QtQuick

QtObject {
  id: root

  // Subsequence fuzzy score. Higher is better. 0 = no match.
  function score(query, text) {
    if (!query || query.length === 0)
      return 1
    if (!text)
      return 0
    var q = query.toLowerCase()
    var t = text.toLowerCase()
    if (t === q)
      return 1000
    if (t.startsWith(q))
      return 800 - Math.min(q.length, 100)
    if (t.indexOf(q) >= 0)
      return 500 - t.indexOf(q)

    var qi = 0
    var consecutive = 0
    var bonus = 0
    for (var i = 0; i < t.length && qi < q.length; i++) {
      if (t.charAt(i) === q.charAt(qi)) {
        qi++
        consecutive++
        bonus += consecutive * 2
      } else {
        consecutive = 0
      }
    }
    if (qi < q.length)
      return 0
    return 100 + bonus - Math.max(0, t.length - q.length)
  }

  function matches(query, text) {
    return score(query, text) > 0
  }

  // Match against title/subtitle/category/keywords/route
  function itemScore(query, item) {
    if (!query || query.trim() === "")
      return 1
    if (!item || item.isHeader)
      return 0
    var best = score(query, item.title || "")
    best = Math.max(best, score(query, item.subtitle || "") * 0.7)
    best = Math.max(best, score(query, item.category || "") * 0.5)
    best = Math.max(best, score(query, item.badge || "") * 0.4)
    if (item.keyword)
      best = Math.max(best, score(query, item.keyword) * 1.2)
    if (item.alias)
      best = Math.max(best, score(query, item.alias) * 1.5)
    if (item.route)
      best = Math.max(best, score(query, item.route) * 1.1)
    if (item.exec)
      best = Math.max(best, score(query, String(item.exec)) * 0.9)
    return best
  }
}
