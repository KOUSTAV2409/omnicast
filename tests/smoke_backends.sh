#!/usr/bin/env bash
# Smoke: Python backends respond; required Omarchy helpers exist on PATH.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
fail=0

pass() { printf 'ok  %s\n' "$1"; }
bad()  { printf 'FAIL %s\n' "$1"; fail=1; }

need_cmd() {
  if command -v "$1" >/dev/null 2>&1; then pass "cmd:$1"
  else bad "cmd:$1 missing"
  fi
}

# Core runtime. Quickshell is required on Omarchy; GitHub runners do not have it.
need_cmd python3
if command -v qs >/dev/null 2>&1; then
  pass "cmd:qs"
elif [[ "${OMNICAST_REQUIRE_OMARCHY:-0}" == "1" ]]; then
  bad "cmd:qs missing"
else
  printf 'skip cmd:qs (not on this machine)\n'
fi

if [[ "${OMNICAST_REQUIRE_OMARCHY:-0}" == "1" ]]; then
  for c in qs hyprctl omarchy fd wl-copy \
           omarchy-menu-clipboard omarchy-menu-emoji \
           omarchy-hyprland-window-pop omarchy-hyprland-window-gaps-toggle; do
    need_cmd "$c"
  done
fi

run_meta() {
  local label="$1"; shift
  local out
  if ! out="$("$@" 2>&1)"; then
    bad "$label (exit $?)"
    return
  fi
  if echo "$out" | grep -q '"ok"[[:space:]]*:[[:space:]]*true\|"ok": true'; then
    pass "$label"
  elif echo "$out" | grep -q '^\[' || echo "$out" | grep -q '"count"'; then
    pass "$label"
  else
    bad "$label unexpected: ${out:0:120}"
  fi
}

run_meta "app_indexer" python3 src/backend/app_indexer.py
run_meta "omarchy_commands" python3 src/backend/omarchy_commands.py
run_meta "script_runner scan" python3 src/backend/script_runner.py scan
run_meta "quicklinks list" python3 src/backend/quicklinks.py list
# Empty ranking is a JSON object with no "ok" or "count". Accept the schema.
ranking_out="$(python3 src/backend/ranking.py dump)"
if echo "$ranking_out" | grep -q '"favorites"' && echo "$ranking_out" | grep -q '"scores"'; then
  pass "ranking dump"
else
  bad "ranking dump"
fi

# snippet list prints JSON array
if python3 src/backend/snippet_manager.py list >/dev/null 2>&1; then
  pass "snippet_manager list"
else
  bad "snippet_manager list"
fi

# file search via stdin
if echo '{"query":"README","scope":"home","limit":3}' | python3 src/backend/file_search.py --stdin | grep -q '"ok"'; then
  pass "file_search --stdin"
else
  bad "file_search --stdin"
fi

# util_io usage / help path (exits non-zero on bare invoke; that is OK)
util_out="$(python3 src/backend/util_io.py 2>&1 || true)"
if echo "$util_out" | grep -qiE 'usage|copy'; then
  pass "util_io responds"
else
  bad "util_io responds"
fi

# path_safety importable
if python3 -c "from pathlib import Path; import sys; sys.path.insert(0,'src/backend'); import path_safety; assert path_safety.is_secret_path(Path.home()/'.ssh'/'id_rsa')"; then
  pass "path_safety import"
else
  bad "path_safety import"
fi

# launcher script exists and is executable
if [[ -x bin/omnicast ]]; then pass "bin/omnicast executable"
else bad "bin/omnicast executable"
fi

if [[ -x bin/omnicast-omarchy-setup ]]; then pass "omarchy-setup executable"
else bad "omarchy-setup executable"
fi

if grep -q 'omnicastBin\|resolvedUrl("bin/omnicast")' BarWidget.qml; then
  pass "BarWidget plugin-local bin"
else
  bad "BarWidget plugin-local bin"
fi

# snippet daemon must NOT exist (removed for security)
if [[ -e bin/omnicast-snippetd ]]; then bad "snippetd should be removed"
else pass "no snippetd binary"
fi

# root JS modules present
for f in Calc.js Handoffs.js WindowActions.js; do
  if [[ -f "src/views/root/$f" ]]; then pass "module:$f"
  else bad "module:$f"
  fi
done
if [[ -f src/services/PathSafety.js ]]; then pass "module:PathSafety.js"
else bad "module:PathSafety.js"
fi

# path_safety CLI: secrets denied, normal home file ok
ssh_probe="${HOME}/.ssh/id_rsa"
if [[ -e $ssh_probe ]] || mkdir -p "${HOME}/.ssh" 2>/dev/null; then
  if python3 src/backend/path_safety.py check "$ssh_probe" >/dev/null 2>&1; then
    bad "path_safety should deny ~/.ssh"
  else
    pass "path_safety denies ~/.ssh"
  fi
fi
tmpf="$(mktemp "${HOME}/omnicast-smoke-XXXXXX.txt")"
echo ok >"$tmpf"
if python3 src/backend/path_safety.py check "$tmpf" >/dev/null 2>&1; then
  pass "path_safety allows home tempfile"
else
  bad "path_safety allows home tempfile"
fi
rm -f "$tmpf"

# ranking prune helpers import
if python3 -c "from ranking import _prune, MAX_SCORES; d=_prune({'scores':{str(i):{'score':i,'last':0} for i in range(MAX_SCORES+50)},'aliases':{},'favorites':[],'recent':[]}); assert len(d['scores'])<=MAX_SCORES" 2>/dev/null; then
  pass "ranking prune cap"
else
  (cd src/backend && python3 -c "from ranking import _prune, MAX_SCORES; d=_prune({'scores':{str(i):{'score':i,'last':0} for i in range(MAX_SCORES+50)},'aliases':{},'favorites':[],'recent':[]}); assert len(d['scores'])<=MAX_SCORES") && pass "ranking prune cap" || bad "ranking prune cap"
fi

# window snap backend
if python3 src/backend/window_snap.py list 2>/dev/null | grep -q '"ok"[[:space:]]*:[[:space:]]*true\|"ok": true'; then
  pass "window_snap list"
else
  bad "window_snap list"
fi

# deeplink help path
if ./bin/omnicast --help 2>&1 | grep -qi snap; then
  pass "omnicast --help"
else
  bad "omnicast --help"
fi

if ./bin/omnicast --help 2>&1 | grep -q plugins; then
  pass "omnicast help lists plugins"
else
  bad "omnicast help lists plugins"
fi

run_meta "plugin_catalog scan" python3 src/backend/plugin_catalog.py scan

if echo '{"op":"enable","id":"../etc/passwd"}' | python3 src/backend/plugin_catalog.py op-json | grep -q '"ok": false'; then
  pass "plugin_catalog rejects bad id"
else
  bad "plugin_catalog rejects bad id"
fi

if (cd src/backend && python3 -c "
import plugin_catalog as p
assert p.extract_git_url('omarchy plugin add https://github.com/a/b.git --enable').endswith('.git')
assert p.extract_git_url('omarchy plugin add https://github.com/a/b.git;id') == ''
assert not p.git_url_ok('http://github.com/a/b.git')
assert not p.git_url_ok('https://user:pw@github.com/a/b.git')
assert p.valid_id('koustav.omnicast')
assert not p.valid_id('../x')
"); then
  pass "plugin_catalog url guards"
else
  bad "plugin_catalog url guards"
fi

run_meta "ai_gateway status" python3 src/backend/ai_gateway.py status

if echo '{"prompt":"","mode":"ask"}' | python3 src/backend/ai_gateway.py chat | grep -q '"type": "error"'; then
  pass "ai_gateway rejects empty prompt"
else
  bad "ai_gateway rejects empty prompt"
fi

if (cd src/backend && python3 -c "
import json
import ai_gateway as a
pub = a.public_config({'provider':'ollama','model':'x','api_key':'secret-key','ollama_url':'http://127.0.0.1:11434','openai_base':'https://api.openai.com/v1'})
blob = json.dumps(pub)
assert 'secret-key' not in blob
assert 'api_key' not in blob
assert a.ollama_url_ok('http://127.0.0.1:11434')
assert not a.ollama_url_ok('http://169.254.169.254/')
assert a.openai_base_ok('https://api.openai.com/v1')
assert a.openai_base_ok('http://127.0.0.1:8080/v1')
assert not a.openai_base_ok('http://evil.example/v1')
assert a.looks_secret('-----BEGIN OPENSSH PRIVATE KEY-----\nabc')
"); then
  pass "ai_gateway guards"
else
  bad "ai_gateway guards"
fi

# PKGBUILD sanity
if [[ -f packaging/aur/PKGBUILD ]]; then
  if grep -q 'python-evdev' packaging/aur/PKGBUILD; then
    bad "PKGBUILD still mentions python-evdev (snippetd)"
  else
    pass "PKGBUILD no evdev/snippetd"
  fi
fi

if [[ "$fail" -ne 0 ]]; then
  echo "smoke: $fail failure(s)" >&2
  exit 1
fi
echo "smoke: all checks passed"
