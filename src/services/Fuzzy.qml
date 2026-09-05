pragma Singleton
import QtQuick

QtObject {
  id: root

  function isSep(ch) {
    return " \t-_/.:|[](){}".indexOf(ch) >= 0
  }

  function isBoundaryBefore(text, idx) {
    if (idx <= 0)
      return true
    return isSep(text.charAt(idx - 1))
  }

  function isBoundaryAfter(text, idx, len) {
    var end = idx + len
    if (end >= text.length)
      return true
    return isSep(text.charAt(end))
  }

  // Match whole tokens only (float ≠ floating, unit ≠ community)
  function tokenScore(query, text) {
    var t = text.toLowerCase()
    var q = query.toLowerCase()
    var start = 0
    var best = 0
    for (var i = 0; i <= t.length; i++) {
      var atEnd = i === t.length
      var sep = !atEnd && isSep(t.charAt(i))
      if (atEnd || sep) {
        if (i > start) {
          var tok = t.substring(start, i)
          if (tok === q)
            best = Math.max(best, 950 - Math.min(start, 40))
          else if (tok.startsWith(q) && q.length >= 3)
            // Prefix of a token only for longer queries (them→theme)
            best = Math.max(best, 700 - Math.min(start, 60) - (tok.length - q.length) * 8)
        }
        start = i + 1
      }
    }
    return best
  }

  // Higher is better. 0 = no match.
  // Contiguous / token matching only: no sparse subsequence.
  function score(query, text) {
    if (!query || query.length === 0)
      return 1
    if (!text)
      return 0
    var q = query.toLowerCase()
    var t = text.toLowerCase()

    if (t === q)
      return 1000
    if (t.startsWith(q) && isBoundaryAfter(t, 0, q.length))
      return 920 - Math.min(t.length - q.length, 80)

    var tok = tokenScore(q, t)
    if (tok > 0)
      return tok

    // Contiguous substring only if both ends are token boundaries
    // (avoids float⊂floating, unit⊂community)
    var idx = t.indexOf(q)
    if (idx >= 0 && isBoundaryBefore(t, idx) && isBoundaryAfter(t, idx, q.length))
      return 740 - Math.min(idx, 100)

    return 0
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

    // Subtitles are descriptive prose: exact/token only, never weak prefixes
    if (q.length > 2) {
      var sub = score(q, item.subtitle || "")
      // Only keep strong subtitle hits (whole token / exact-ish)
      if (sub >= 700)
        best = Math.max(best, sub * 0.55)
    }
    best = Math.max(best, score(q, item.category || "") * 0.3)
    best = Math.max(best, score(q, item.badge || "") * 0.25)
    if (item.keyword)
      best = Math.max(best, score(q, item.keyword) * 1.15)
    if (item.alias)
      best = Math.max(best, score(q, item.alias) * 1.4)
    if (item.route)
      best = Math.max(best, score(q, item.route) * 1.05)
    if (item.exec && q.length >= 4) {
      var ex = String(item.exec).trim()
      var firstTok = ex.split(/\s+/)[0] || ""
      var base = firstTok.split("/").pop() || firstTok
      best = Math.max(best, score(q, base) * 0.75)
    }
    return best
  }
}
