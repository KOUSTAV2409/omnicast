// Pure calculator helpers for root search (math, color, units, FX, dates).
.pragma library

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
