// Client-side sensitive-path checks (keep aligned with backend path_safety.py).
.pragma library

function isSensitivePath(path) {
  var p = String(path || "").toLowerCase().replace(/\\/g, "/")
  if (!p.length)
    return true
  // Normalize so "/home/u/.ssh" matches "/.ssh/" (same as path_safety.py).
  if (p[p.length - 1] !== "/")
    p = p + "/"
  var parts = [
    "/.ssh/", "/.gnupg/", "/.gpg/", "/.aws/", "/.azure/", "/.kube/", "/.docker/",
    "/.password-store/", "/.config/gcloud/", "/.config/gh/",
    "/.config/chromium/", "/.config/google-chrome/", "/.config/bravesoftware/",
    "/.config/microsoft-edge/", "/.mozilla/firefox/", "/.thunderbird/",
    "/.local/share/keyrings/", "/.local/share/kwalletd/",
    "/.config/keepassxc/", "/.config/bitwarden/", "/.config/1password/",
    "/.config/op/", "/.config/signal/", "/.config/element/",
    "/.config/discord/", "/.config/slack/", "/.electrum/",
    "/.var/app/org.mozilla.firefox/", "/.var/app/com.google.chrome/",
    "/.var/app/com.brave.browser/"
  ]
  for (var i = 0; i < parts.length; i++) {
    if (p.indexOf(parts[i]) >= 0)
      return true
  }
  var trimmed = p.replace(/\/+$/, "")
  var base = trimmed.split("/").pop() || ""
  if (base === ".env" || base.indexOf(".env.") === 0 || base === ".envrc")
    return true
  if (base.indexOf("id_rsa") === 0 || base.indexOf("id_ed25519") === 0
      || base.indexOf("id_ecdsa") === 0 || base.indexOf("id_dsa") === 0)
    return true
  if (/\.(pem|key|p12|pfx|jks|kdbx|kdb|asc)$/.test(base))
    return true
  if (base === ".netrc" || base === ".pgpass" || base === ".npmrc" || base === ".pypirc"
      || base === ".git-credentials" || base === "credentials.json"
      || base === "service_account.json" || base === "secrets.json"
      || base === "secrets.toml" || base === "secrets.yaml" || base === "secrets.yml"
      || base === "logins.json" || base === "cookies.sqlite" || base === "key4.db"
      || base === "cert9.db" || base === "login data" || base === "cookies")
    return true
  return false
}

function isDangerousOpenExt(path) {
  return /\.(sh|bash|zsh|fish|py|rb|pl|js|mjs|cjs|exe|bin|run|appimage)$/i.test(String(path || ""))
}
