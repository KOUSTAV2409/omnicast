#!/usr/bin/env python3
"""Local path containment + secret denial for Omnicast file tools.

Omnicast is a same-user desktop launcher. These guards stop accidental
disclosure of keys, tokens, and browser/session stores via search/preview
cache, and keep results under $HOME (and the active scope).
"""
from __future__ import annotations

import json
import os
import re
from pathlib import Path

# Directory path segments that must never appear in search/preview.
SECRET_DIR_PARTS = (
    "/.ssh/",
    "/.gnupg/",
    "/.gpg/",
    "/.password-store/",
    "/.aws/",
    "/.azure/",
    "/.kube/",
    "/.docker/",
    "/.config/gcloud/",
    "/.config/gh/",
    "/.config/keepassxc/",
    "/.config/chromium/",
    "/.config/google-chrome/",
    "/.config/BraveSoftware/",
    "/.config/microsoft-edge/",
    "/.mozilla/firefox/",
    "/.thunderbird/",
    "/.local/share/keyrings/",
    "/.local/share/kwalletd/",
    "/.config/Element/",
    "/.config/Signal/",
    "/.config/discord/",
    "/.config/slack/",
    "/.config/Bitwarden/",
    "/.config/1Password/",
    "/.electrum/",
    "/Library/Keychains/",  # macOS-ish; harmless on Linux
)

# Exact / suffix filenames that are typically credentials.
SECRET_NAMES = {
    ".netrc",
    ".pgpass",
    ".npmrc",
    ".pypirc",
    ".git-credentials",
    ".env",
    ".env.local",
    ".env.development",
    ".env.production",
    ".env.staging",
    "id_rsa",
    "id_dsa",
    "id_ecdsa",
    "id_ed25519",
    "id_ecdsa_sk",
    "id_ed25519_sk",
    "authorized_keys",
    "known_hosts",
    "credentials",
    "credentials.json",
    "credentials.csv",
    "service_account.json",
    "secrets.json",
    "secrets.yaml",
    "secrets.yml",
    "token",
    "token.json",
    "cookies",
    "cookies.sqlite",
    "login data",
    "logins.json",
    "key4.db",
    "cert9.db",
    "shadow",
    "gshadow",
    "master_password.aes",
}

SECRET_SUFFIXES = (
    ".pem",
    ".key",
    ".p12",
    ".pfx",
    ".jks",
    ".kdbx",
    ".kdb",
    ".asc",  # often armored private material
)

# Extra rg --glob denials (content search).
SECRET_RG_GLOBS = [
    "!.ssh/**",
    "!.gnupg/**",
    "!.password-store/**",
    "!.aws/**",
    "!.azure/**",
    "!.kube/**",
    "!.docker/**",
    "!.config/gcloud/**",
    "!.config/gh/**",
    "!.config/keepassxc/**",
    "!.config/chromium/**",
    "!.config/google-chrome/**",
    "!.config/BraveSoftware/**",
    "!.mozilla/firefox/**",
    "!.local/share/keyrings/**",
    "!.env",
    "!.env.*",
    "!**/.env",
    "!**/.env.*",
    "!**/id_rsa",
    "!**/id_ed25519",
    "!**/id_ecdsa",
    "!**/*.pem",
    "!**/*.key",
    "!**/*.p12",
    "!**/*.pfx",
    "!**/*.kdbx",
    "!**/.netrc",
    "!**/.git-credentials",
    "!**/credentials.json",
    "!**/service_account.json",
    "!**/Cookies",
    "!**/Login Data",
    "!**/logins.json",
]


def home() -> Path:
    return Path.home().resolve()


def cache_dir() -> Path:
    base = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache"))
    d = (base / "omnicast").resolve()
    d.mkdir(parents=True, exist_ok=True)
    try:
        os.chmod(d, 0o700)
    except Exception:
        pass
    return d


def safe_cache_name(name: str, default: str = "cache.json") -> str:
    """Basename only — no directory separators or traversal."""
    raw = (name or "").strip().replace("\\", "/")
    base = Path(raw).name
    if not base or base in {".", ".."} or "/" in base:
        return default
    if not re.fullmatch(r"[A-Za-z0-9._-]+", base):
        return default
    return base


def write_secure_json(path: Path, payload: dict | list) -> Path:
    """Write JSON with mode 0600 (owner-only)."""
    path = Path(path)
    parent = path.parent
    parent.mkdir(parents=True, exist_ok=True)
    try:
        os.chmod(parent, 0o700)
    except Exception:
        pass
    data = json.dumps(payload, ensure_ascii=False)
    # Atomic-ish replace with restrictive perms
    tmp = path.with_suffix(path.suffix + ".tmp")
    flags = os.O_WRONLY | os.O_CREAT | os.O_TRUNC
    fd = os.open(str(tmp), flags, 0o600)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            f.write(data)
            f.flush()
            os.fsync(f.fileno())
    except Exception:
        try:
            os.close(fd)
        except Exception:
            pass
        raise
    os.replace(tmp, path)
    try:
        os.chmod(path, 0o600)
    except Exception:
        pass
    return path


def _norm(path: Path) -> str:
    try:
        return str(path.resolve()).replace("\\", "/").lower()
    except Exception:
        return str(path).replace("\\", "/").lower()


def is_secret_path(path: Path) -> bool:
    """True if this path looks like credentials / session stores."""
    try:
        resolved = path.resolve()
    except Exception:
        resolved = path
    full = "/" + _norm(resolved).strip("/") + "/"
    name = resolved.name.lower()

    for part in SECRET_DIR_PARTS:
        if part.lower() in full:
            return True

    if name in SECRET_NAMES or name.startswith(".env"):
        return True
    if any(name.endswith(suf) for suf in SECRET_SUFFIXES):
        return True
    # Private keys without extension (OpenSSH often bare names)
    if name.startswith("id_") and not name.endswith(".pub"):
        return True
    return False


def is_under(path: Path, root: Path) -> bool:
    """True if resolved path is root or a descendant (symlink-aware)."""
    try:
        p = path.resolve()
        r = root.resolve()
    except Exception:
        return False
    try:
        p.relative_to(r)
        return True
    except ValueError:
        return False


def allowed_path(path: Path, scope_root: Path | None = None) -> bool:
    """Search/preview may only touch non-secret paths under $HOME (and scope)."""
    try:
        p = path.expanduser().resolve()
    except Exception:
        return False
    if not is_under(p, home()):
        return False
    if scope_root is not None and not is_under(p, scope_root):
        return False
    if is_secret_path(p):
        return False
    return True


def deny_reason(path: Path, scope_root: Path | None = None) -> str:
    try:
        p = path.expanduser().resolve()
    except Exception:
        return "Invalid path"
    if not is_under(p, home()):
        return "Outside home directory"
    if scope_root is not None and not is_under(p, scope_root):
        return "Outside current search scope"
    if is_secret_path(p):
        return "Blocked: sensitive credentials or session data"
    return ""
