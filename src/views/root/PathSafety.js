// Client-side sensitive-path checks (mirrors backend path_safety intent).
.pragma library

function isSensitivePath(path) {
  var p = String(path || "").toLowerCase().replace(/\\/g, "/")
  if (!p.length)
    return true
  var parts = [
    "/.ssh/", "/.gnupg/", "/.aws/", "/.azure/", "/.kube/", "/.docker/",
    "/.password-store/", "/.config/gcloud/", "/.config/chromium/",
    "/.config/google-chrome/", "/.mozilla/firefox/", "/.local/share/keyrings/",
    "/.config/keepassxc/", "/.config/bitwarden/", "/.config/1password/",
    "/.config/signal/", "/.config/element/"
  ]
  for (var i = 0; i < parts.length; i++) {
    if (p.indexOf(parts[i]) >= 0)
      return true
  }
  var base = p.split("/").pop()
  if (base === ".env" || base.indexOf(".env.") === 0)
    return true
  if (base.indexOf("id_rsa") === 0 || base.indexOf("id_ed25519") === 0 || base.indexOf("id_ecdsa") === 0)
    return true
  if (/\.(pem|key|p12|pfx|kdbx)$/.test(base))
    return true
  if (base === ".netrc" || base === ".git-credentials" || base === "credentials.json")
    return true
  return false
}
