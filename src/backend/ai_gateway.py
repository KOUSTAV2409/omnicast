#!/usr/bin/env python3
"""Local-first AI gateway. Ollama by default, OpenAI-compatible BYOK optional.

Streams newline-delimited JSON. The API key stays in ~/.config/omnicast/ai.json
and is never printed. Prompts arrive on stdin, never on the command line.
"""
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import urllib.error
import urllib.request
from pathlib import Path
from urllib.parse import urlparse

CONFIG = Path.home() / ".config" / "omnicast" / "ai.json"
MAX_PROMPT = 16000
MAX_CLIPBOARD = 8000
MODEL_RE = re.compile(r"^[A-Za-z0-9_.:/@+\-]{1,128}$")
SECRET_RE = re.compile(
    r"(-----BEGIN [A-Z0-9 ]*PRIVATE KEY-----|\b(?:sk-|ghp_|github_pat_|xox[baprs]-|AKIA)[A-Za-z0-9_\-]{8,})"
)

DEFAULT = {
    "provider": "ollama",
    "ollama_url": "http://127.0.0.1:11434",
    "model": "",
    "openai_base": "https://api.openai.com/v1",
    "api_key": "",
}


def emit(payload: dict) -> None:
    print(json.dumps(payload, ensure_ascii=False), flush=True)


def _loopback(host: str) -> bool:
    return host in {"localhost", "127.0.0.1", "::1"}


def ollama_url_ok(url: str) -> bool:
    try:
        parsed = urlparse((url or "").strip())
    except Exception:
        return False
    if parsed.scheme != "http" or parsed.username or parsed.password or parsed.query or parsed.fragment:
        return False
    if "@" in (parsed.netloc or ""):
        return False
    host = (parsed.hostname or "").lower()
    if not _loopback(host):
        return False
    path = parsed.path or ""
    return path in {"", "/"}


def openai_base_ok(url: str) -> bool:
    try:
        parsed = urlparse((url or "").strip())
    except Exception:
        return False
    if parsed.username or parsed.password or "@" in (parsed.netloc or "") or parsed.query or parsed.fragment:
        return False
    host = (parsed.hostname or "").lower()
    if not host:
        return False
    path = parsed.path or ""
    if ".." in path or "\\" in path:
        return False
    if parsed.scheme == "https" and not _loopback(host) and not re.fullmatch(r"\d+\.\d+\.\d+\.\d+", host):
        return True
    if parsed.scheme == "http" and _loopback(host):
        return True
    return False


def model_ok(name: str) -> bool:
    return bool(MODEL_RE.fullmatch(name or ""))


def looks_secret(text: str) -> bool:
    return bool(SECRET_RE.search(text or ""))


def _ensure_config_perms() -> None:
    CONFIG.parent.mkdir(parents=True, exist_ok=True)
    try:
        os.chmod(CONFIG.parent, 0o700)
    except OSError:
        pass


def load_config() -> dict:
    cfg = dict(DEFAULT)
    _ensure_config_perms()
    if not CONFIG.exists():
        return cfg
    try:
        with open(CONFIG, encoding="utf-8") as handle:
            data = json.load(handle)
    except Exception:
        return cfg
    if not isinstance(data, dict):
        return cfg
    provider = str(data.get("provider") or "")
    if provider in {"ollama", "openai"}:
        cfg["provider"] = provider
    ollama_url = str(data.get("ollama_url") or "")
    if ollama_url_ok(ollama_url):
        cfg["ollama_url"] = ollama_url.rstrip("/")
    base = str(data.get("openai_base") or "")
    if openai_base_ok(base):
        cfg["openai_base"] = base.rstrip("/")
    model = str(data.get("model") or "")
    if not model or model_ok(model):
        cfg["model"] = model
    key = data.get("api_key")
    if isinstance(key, str):
        cfg["api_key"] = key
    return cfg


def save_config(cfg: dict) -> None:
    _ensure_config_perms()
    payload = {
        "provider": cfg.get("provider") or "ollama",
        "ollama_url": cfg.get("ollama_url") or DEFAULT["ollama_url"],
        "model": cfg.get("model") or "",
        "openai_base": cfg.get("openai_base") or DEFAULT["openai_base"],
        "api_key": cfg.get("api_key") or "",
    }
    tmp = CONFIG.with_suffix(".json.tmp")
    fd = os.open(str(tmp), os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            json.dump(payload, handle)
            handle.flush()
            os.fsync(handle.fileno())
    except Exception:
        try:
            os.close(fd)
        except OSError:
            pass
        raise
    os.replace(tmp, CONFIG)
    try:
        os.chmod(CONFIG, 0o600)
    except OSError:
        pass


def public_config(cfg: dict, reachable: bool = False, models: list[str] | None = None) -> dict:
    names = []
    for name in models or []:
        if model_ok(name) and name not in names:
            names.append(name)
        if len(names) >= 40:
            break
    provider = cfg.get("provider") or "ollama"
    endpoint = cfg.get("ollama_url") if provider == "ollama" else cfg.get("openai_base")
    return {
        "ok": True,
        "provider": provider,
        "model": cfg.get("model") or "",
        "reachable": bool(reachable),
        "has_key": bool(cfg.get("api_key")),
        "models": names,
        "endpoint": endpoint or "",
        "ollama_url": cfg.get("ollama_url") or "",
        "openai_base": cfg.get("openai_base") or "",
    }


def _get_json(url: str, headers: dict | None = None, timeout: float = 2.0):
    req = urllib.request.Request(url, headers=headers or {})
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return json.loads(resp.read().decode("utf-8"))


def ollama_models(cfg: dict) -> tuple[bool, list[str]]:
    try:
        data = _get_json(cfg["ollama_url"].rstrip("/") + "/api/tags", timeout=2.0)
    except Exception:
        return False, []
    names = []
    for row in data.get("models") or []:
        if isinstance(row, dict) and row.get("name"):
            names.append(str(row["name"]))
    return True, names


def openai_models(cfg: dict) -> tuple[bool, list[str]]:
    key = cfg.get("api_key") or ""
    if not key:
        return False, []
    try:
        data = _get_json(
            cfg["openai_base"].rstrip("/") + "/models",
            headers={"Authorization": "Bearer " + key},
            timeout=4.0,
        )
    except Exception:
        return False, []
    names = []
    for row in data.get("data") or []:
        if isinstance(row, dict) and row.get("id"):
            names.append(str(row["id"]))
    return True, names


def probe(cfg: dict) -> tuple[bool, list[str]]:
    if cfg.get("provider") == "openai":
        return openai_models(cfg)
    return ollama_models(cfg)


def resolve_model(cfg: dict, models: list[str]) -> str:
    want = (cfg.get("model") or "").strip()
    if want and model_ok(want):
        return want
    for name in models:
        if model_ok(name):
            return name
    if cfg.get("provider") == "openai":
        return "gpt-4o-mini"
    return "llama3.2"


def read_clip(primary: bool) -> str:
    cmd = ["wl-paste", "--no-newline"]
    if primary:
        cmd.append("--primary")
    try:
        text = subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL, timeout=2)
    except Exception:
        return ""
    if "\x00" in text:
        return ""
    return text[:MAX_CLIPBOARD]


def build_messages(mode: str, prompt: str, source: str) -> list[dict]:
    instructions = {
        "ask": "Answer concisely.",
        "explain": "Explain the following text clearly, in short paragraphs.",
        "summarize": "Summarize the following text in at most 5 bullets.",
        "grammar": "Correct grammar and typos. Return only the revised text.",
    }
    guide = instructions.get(mode) or instructions["ask"]
    system = "You are Omnicast, a local assistant on Omarchy Linux. " + guide
    return [
        {"role": "system", "content": system},
        {"role": "user", "content": prompt},
    ]


def _stream(url: str, body: dict, headers: dict):
    data = json.dumps(body).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers=headers, method="POST")
    return urllib.request.urlopen(req, timeout=120)


def stream_ollama(cfg: dict, model: str, messages: list[dict]) -> None:
    url = cfg["ollama_url"].rstrip("/") + "/api/chat"
    body = {"model": model, "messages": messages, "stream": True}
    with _stream(url, body, {"Content-Type": "application/json"}) as resp:
        for raw in resp:
            line = raw.decode("utf-8", "replace").strip()
            if not line:
                continue
            obj = json.loads(line)
            if obj.get("error"):
                raise RuntimeError(str(obj.get("error"))[:180])
            piece = ((obj.get("message") or {}).get("content")) or ""
            if piece:
                emit({"type": "delta", "text": piece})
            if obj.get("done"):
                break


def stream_openai(cfg: dict, model: str, messages: list[dict]) -> None:
    key = cfg.get("api_key") or ""
    if not key:
        raise RuntimeError("No API key. Set one in Ask AI → Settings.")
    url = cfg["openai_base"].rstrip("/") + "/chat/completions"
    body = {"model": model, "messages": messages, "stream": True}
    headers = {"Content-Type": "application/json", "Authorization": "Bearer " + key}
    with _stream(url, body, headers) as resp:
        for raw in resp:
            line = raw.decode("utf-8", "replace").strip()
            if not line.startswith("data:"):
                continue
            data = line[5:].strip()
            if data == "[DONE]":
                break
            obj = json.loads(data)
            if obj.get("error"):
                message = obj["error"]
                if isinstance(message, dict):
                    message = message.get("message") or "request failed"
                raise RuntimeError(str(message)[:180])
            choices = obj.get("choices") or []
            if not choices:
                continue
            delta = (choices[0].get("delta") or {}).get("content") or ""
            if delta:
                emit({"type": "delta", "text": delta})


def friendly_error(exc: Exception) -> str:
    if isinstance(exc, urllib.error.URLError) and getattr(exc, "reason", None):
        reason = str(exc.reason)
        if "refused" in reason or "111" in reason:
            return "Ollama is not running, or the endpoint refused the connection."
        return reason[:180]
    if isinstance(exc, TimeoutError):
        return "The model endpoint timed out."
    return str(exc)[:180] or "AI request failed"


def chat(payload: dict) -> None:
    cfg = load_config()
    mode = str(payload.get("mode") or "ask")
    if mode not in {"ask", "explain", "summarize", "grammar"}:
        emit({"type": "error", "error": "unknown mode"})
        return
    source = str(payload.get("source") or "prompt")
    if source == "clipboard":
        prompt = read_clip(False)
        if not prompt.strip():
            emit({"type": "error", "error": "Clipboard is empty"})
            return
    elif source == "selection":
        prompt = read_clip(True) or read_clip(False)
        if not prompt.strip():
            emit({"type": "error", "error": "Selection is empty"})
            return
    else:
        prompt = str(payload.get("prompt") or "")
    prompt = prompt.strip()
    if not prompt:
        emit({"type": "error", "error": "empty prompt"})
        return
    if len(prompt) > MAX_PROMPT:
        prompt = prompt[:MAX_PROMPT]
    if looks_secret(prompt):
        emit({"type": "error", "error": "Refusing to send text that looks like a key or token"})
        return
    reachable, models = probe(cfg)
    model = resolve_model(cfg, models)
    if not model_ok(model):
        emit({"type": "error", "error": "invalid model name"})
        return
    if cfg.get("provider") == "ollama" and not reachable and not (cfg.get("model") or ""):
        emit({"type": "error", "error": "Ollama is not running. Start it, or set an OpenAI-compatible endpoint."})
        return
    emit({"type": "meta", "provider": cfg.get("provider"), "model": model})
    messages = build_messages(mode, prompt, source)
    try:
        if cfg.get("provider") == "openai":
            stream_openai(cfg, model, messages)
        else:
            stream_ollama(cfg, model, messages)
    except Exception as exc:
        emit({"type": "error", "error": friendly_error(exc)})
        return
    emit({"type": "done"})


def apply_update(patch: dict) -> dict:
    if not isinstance(patch, dict):
        raise ValueError("invalid settings")
    cfg = load_config()
    if "provider" in patch and str(patch.get("provider") or ""):
        provider = str(patch.get("provider") or "")
        if provider not in {"ollama", "openai"}:
            raise ValueError("provider must be ollama or openai")
        cfg["provider"] = provider
    if "model" in patch:
        model = str(patch.get("model") or "").strip()
        if model and not model_ok(model):
            raise ValueError("invalid model name")
        cfg["model"] = model
    if "ollama_url" in patch and str(patch.get("ollama_url") or ""):
        url = str(patch.get("ollama_url") or "").strip()
        if not ollama_url_ok(url):
            raise ValueError("Ollama URL must be loopback http")
        cfg["ollama_url"] = url.rstrip("/")
    if "openai_base" in patch and str(patch.get("openai_base") or ""):
        base = str(patch.get("openai_base") or "").strip()
        if not openai_base_ok(base):
            raise ValueError("endpoint must be https, or http on localhost")
        cfg["openai_base"] = base.rstrip("/")
    if patch.get("clear_key"):
        cfg["api_key"] = ""
    elif isinstance(patch.get("api_key"), str) and patch.get("api_key"):
        cfg["api_key"] = str(patch.get("api_key"))
    save_config(cfg)
    reachable, models = probe(cfg)
    return public_config(cfg, reachable, models)


def status() -> dict:
    cfg = load_config()
    reachable, models = probe(cfg)
    return public_config(cfg, reachable, models)


def main() -> int:
    cmd = sys.argv[1] if len(sys.argv) > 1 else "status"
    if cmd == "status":
        print(json.dumps(status()))
        return 0
    if cmd == "set":
        try:
            patch = json.loads(sys.stdin.readline() or "{}")
            print(json.dumps(apply_update(patch)))
        except Exception as exc:
            print(json.dumps({"ok": False, "error": str(exc)[:180]}))
        return 0
    if cmd == "chat":
        try:
            payload = json.loads(sys.stdin.readline() or "{}")
        except json.JSONDecodeError:
            emit({"type": "error", "error": "invalid json"})
            return 0
        if not isinstance(payload, dict):
            emit({"type": "error", "error": "invalid json"})
            return 0
        chat(payload)
        return 0
    print(json.dumps({"ok": False, "error": "usage: status|set|chat"}))
    return 1


if __name__ == "__main__":
    sys.exit(main())
