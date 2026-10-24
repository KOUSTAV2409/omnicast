// Pure calculator helpers for root search (math, color, units, FX, dates).
// Math uses a recursive-descent parser — never Function()/eval.
.pragma library

var MAX_EXPR_LEN = 64
var MAX_NUMBER = 1e15
var MAX_EXP = 20

function tryMathEvaluation(query) {
  if (!query) return null
  var clean = query.trim()
  if (clean.length > MAX_EXPR_LEN)
    return null
  if (!/^[0-9.\s+\-*/()%^eE]+$/.test(clean) || !/[0-9]/.test(clean) || !/[+\-*/%^]/.test(clean))
    return null
  if ((clean.match(/\^/g) || []).length > 1)
    return null
  try {
    var tokens = _tokenize(clean.replace(/\^/g, "**"))
    var idx = 0
    function peek() { return tokens[idx] }
    function take() { return tokens[idx++] }
    function parseExpr() {
      var v = parseTerm()
      while (peek() === "+" || peek() === "-") {
        var op = take()
        var r = parseTerm()
        v = op === "+" ? v + r : v - r
        _check(v)
      }
      return v
    }
    function parseTerm() {
      var v = parsePower()
      while (peek() === "*" || peek() === "/" || peek() === "%") {
        var op = take()
        var r = parsePower()
        if (op === "*") v = v * r
        else if (op === "/") {
          if (r === 0) throw new Error("div0")
          v = v / r
        } else {
          if (r === 0) throw new Error("mod0")
          v = v % r
        }
        _check(v)
      }
      return v
    }
    function parsePower() {
      var v = parseUnary()
      if (peek() === "**") {
        take()
        var exp = parseUnary()
        if (!Number.isInteger(exp) || exp < 0 || exp > MAX_EXP)
          throw new Error("exp")
        if (Math.abs(v) > 1000 && exp > 8)
          throw new Error("exp")
        v = Math.pow(v, exp)
        _check(v)
      }
      return v
    }
    function parseUnary() {
      if (peek() === "+") { take(); return parseUnary() }
      if (peek() === "-") { take(); return -parseUnary() }
      return parsePrimary()
    }
    function parsePrimary() {
      if (peek() === "(") {
        take()
        var v = parseExpr()
        if (take() !== ")") throw new Error("paren")
        return v
      }
      var t = take()
      if (typeof t !== "number") throw new Error("num")
      return t
    }
    var result = parseExpr()
    if (idx !== tokens.length) throw new Error("trail")
    if (typeof result !== "number" || !isFinite(result)) return null
    _check(result)
    return Number.isInteger(result) ? result.toLocaleString()
           : result.toFixed(6).replace(/\.?0+$/, "")
  } catch (e) {}
  return null
}

function _check(v) {
  if (typeof v !== "number" || !isFinite(v) || Math.abs(v) > MAX_NUMBER)
    throw new Error("range")
}

function _tokenize(s) {
  var out = [], i = 0
  while (i < s.length) {
    var c = s[i]
    if (c === " " || c === "\t") { i++; continue }
    if (c === "*" && s[i + 1] === "*") { out.push("**"); i += 2; continue }
    if ("+-*/%()".indexOf(c) >= 0) { out.push(c); i++; continue }
    if ((c >= "0" && c <= "9") || c === ".") {
      var start = i
      while (i < s.length && ((s[i] >= "0" && s[i] <= "9") || s[i] === "." || s[i] === "e" || s[i] === "E"
             || ((s[i] === "+" || s[i] === "-") && i > start && (s[i - 1] === "e" || s[i - 1] === "E"))))
        i++
      var num = Number(s.slice(start, i))
      if (!isFinite(num)) throw new Error("num")
      if (Math.abs(num) > MAX_NUMBER) throw new Error("range")
      out.push(num)
      continue
    }
    throw new Error("tok")
  }
  return out
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
  var usd = { usd: 1, eur: 0.86, gbp: 0.74, inr: 94.4, jpy: 148.0, aud: 1.48, cad: 1.36 }
  if (usd[from] === undefined || usd[to] === undefined) return null
  if (from === to) return null
  var out = n * (usd[to] / usd[from])
  var rounded = (Math.abs(out) >= 100 ? out.toFixed(2) : out.toFixed(4)).replace(/\.?0+$/, "")
  return {
    approx: "≈ " + rounded + " " + to.toUpperCase() + " ?",
    copyValue: rounded + " " + to.toUpperCase(),
    googleQuery: n + " " + from.toUpperCase() + " to " + to.toUpperCase()
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
    var hh = ("" + now.getHours()), mm = ("" + now.getMinutes())
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
    base.setDate(base.getDate() + parseInt(m[3], 10) * (m[2] === "-" ? -1 : 1))
    return fmt(base)
  }
  return null
}
