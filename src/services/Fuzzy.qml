pragma Singleton
import QtQuick

QtObject {
  id: root

  function isBoundaryBefore(text, idx) {
    if (idx <= 0)
      return true
    return " \t-_/.:|[](){}".indexOf(text.charAt(idx - 1)) >= 0
  }

  function tokenPrefixScore(query, text) {
    var t = text.toLowerCase()
    var q = query.toLowerCase()
    var start = 0
    for (var i = 0; i <= t.length; i++) {
      var atEnd = i === t.length
      var sep = !atEnd && " \t-_/.:|[](){}".indexOf(t.charAt(i)) >= 0
      if (atEnd || sep) {
        if (i > start) {
          var tok = t.substring(start, i)
          if (tok === q)
            return 950
          if (tok.startsWith(q))
            return 820 - Math.min(start, 60)
        }
        start = i + 1
      }
    }
    return 0
  }

  // Higher is better. 0 = no match.
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

    // 1–2 chars: token prefix only
    if (q.length <= 2)
      return tokenPrefixScore(q, t)

    var idx = t.indexOf(q)
    if (idx >= 0) {
      var boundary = isBoundaryBefore(t, idx)
      if (!boundary) {
        // Mid-word ("unit" in Community, "ai" in Tailscale) — reject.
        // Do NOT fall through to subsequence (that re-matches the same letters).
        return 0
      }
      return 740 - Math.min(idx, 100)
    }

    // Tight subsequence for longer queries only
    if (q.length < 4)
      return 0

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
    if (span > q.length * 2 + 1)
      return 0
    if (maxRun < 2)
      return 0

    return 150 + bonus + maxRun * 15 - (span - q.length)
  }

  function matches(query, text) {
    return score(query, text) > 0
  }

  function itemScore(query, item) {
    if (!query || query.trim() === "")
      return 1
    if (!item || item.isHeader)
      return 0

    var q = query.trim()
    var best = score(q, item.title || "")

    if (q.length > 2)
      best = Math.max(best, score(q, item.subtitle || "") * 0.5)
    best = Math.max(best, score(q, item.category || "") * 0.3)
    best = Math.max(best, score(q, item.badge || "") * 0.25)
    if (item.keyword)
      best = Math.max(best, score(q, item.keyword) * 1.15)
    if (item.alias)
      best = Math.max(best, score(q, item.alias) * 1.4)
    if (item.route)
      best = Math.max(best, score(q, item.route) * 1.05)
    // Only score the executable token — not flags like --app-id=TUI.float
    if (item.exec && q.length >= 4) {
      var ex = String(item.exec).trim()
      var firstTok = ex.split(/\s+/)[0] || ""
      var base = firstTok.split("/").pop() || firstTok
      best = Math.max(best, score(q, base) * 0.75)
    }
    return best
  }
}
