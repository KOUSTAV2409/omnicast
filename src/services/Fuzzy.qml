pragma Singleton
import QtQuick

QtObject {
  id: root

  // Higher is better. 0 = no match.
  // Prefer exact / prefix / substring; allow tight subsequence only.
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
      return 900 - Math.min(t.length - q.length, 80)
    var idx = t.indexOf(q)
    if (idx >= 0) {
      // Word-ish boundary bonus
      var boundary = (idx === 0 || " -_/.:".indexOf(t.charAt(idx - 1)) >= 0) ? 40 : 0
      return 700 + boundary - Math.min(idx, 100)
    }

    // Tight subsequence: reject when query letters are sprinkled through a long string
    // (e.g. "foot" inside "Check if hibernation is supported").
    var qi = 0
    var consecutive = 0
    var maxRun = 0
    var bonus = 0
    var first = -1
    var last = -1
    for (var i = 0; i < t.length && qi < q.length; i++) {
      if (t.charAt(i) === q.charAt(qi)) {
        if (first < 0)
          first = i
        last = i
        qi++
        consecutive++
        if (consecutive > maxRun)
          maxRun = consecutive
        bonus += consecutive * 3
      } else {
        consecutive = 0
      }
    }
    if (qi < q.length)
      return 0

    var span = last - first + 1
    // Allow at most ~1 skipped char per query char
    if (span > q.length * 2 + 1)
      return 0
    // Need a short consecutive run for queries longer than 2
    if (q.length >= 3 && maxRun < 2)
      return 0

    return 150 + bonus + maxRun * 15 - (span - q.length)
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
    best = Math.max(best, score(query, item.subtitle || "") * 0.55)
    best = Math.max(best, score(query, item.category || "") * 0.35)
    best = Math.max(best, score(query, item.badge || "") * 0.3)
    if (item.keyword)
      best = Math.max(best, score(query, item.keyword) * 1.15)
    if (item.alias)
      best = Math.max(best, score(query, item.alias) * 1.4)
    if (item.route)
      best = Math.max(best, score(query, item.route) * 1.05)
    if (item.exec)
      best = Math.max(best, score(query, String(item.exec)) * 0.85)
    return best
  }
}
