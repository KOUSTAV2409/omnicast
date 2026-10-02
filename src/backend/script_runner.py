#!/usr/bin/env python3
"""Scan and run Omnicast script commands from allowlisted directories only."""
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
from pathlib import Path

COMMAND_DIRS = [
    Path.home() / ".config/omnicast/commands",
    Path(__file__).resolve().parent.parent / "commands",
]

INTERPRETERS = {
    ".py": ["python3"],
    ".sh": ["bash"],
    ".bash": ["bash"],
    ".js": ["node"],
    ".rb": ["ruby"],
}


def _command_roots() -> list[Path]:
    roots = []
    for d in COMMAND_DIRS:
        try:
            if d.exists():
                roots.append(d.resolve())
            else:
                d.mkdir(parents=True, exist_ok=True)
                roots.append(d.resolve())
        except Exception:
            continue
    return roots


def is_allowed_script(script_path: Path) -> bool:
    try:
        resolved = script_path.expanduser().resolve()
    except Exception:
        return False
    if not resolved.is_file():
        return False
    # Never exec interpreters / system bins by path spoof
    name = resolved.name.lower()
    if name in {"bash", "sh", "zsh", "python", "python3", "node", "ruby", "perl", "dash"}:
        return False
    for root in _command_roots():
        try:
            resolved.relative_to(root)
            return True
        except ValueError:
            continue
    return False


def parse_frontmatter(file_path: Path) -> dict:
    metadata = {
        "id": f"cmd-{file_path.stem}",
        "path": str(file_path.resolve()),
        "title": file_path.stem.replace("-", " ").title(),
        "subtitle": f"Script Command • {file_path.name}",
        "mode": "fullOutput",
        "icon": "⚡",
        "category": "Script Commands",
        "badge": "Script",
        "arguments": [],
    }

    try:
        with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Error parsing {file_path}: {e}", file=sys.stderr)
        return metadata

    for line in lines[:40]:
        line = line.strip()
        m = re.match(r"^#\s*@(omarchy|raycast)\.([a-zA-Z0-9_]+)\s+(.+)$", line)
        if not m:
            continue
        key = m.group(2)
        val = m.group(3).strip()
        if key == "title":
            metadata["title"] = val
        elif key == "mode":
            metadata["mode"] = val
        elif key == "icon":
            metadata["icon"] = val
        elif key == "packageName":
            metadata["category"] = val
        elif key == "description":
            metadata["subtitle"] = val
        elif key.startswith("argument"):
            try:
                arg_data = json.loads(val)
                metadata["arguments"].append(arg_data)
            except Exception:
                metadata["arguments"].append(
                    {
                        "type": "text",
                        "placeholder": val,
                        "name": f"arg{len(metadata['arguments']) + 1}",
                    }
                )
    return metadata


def scan_commands() -> list:
    discovered = []
    for cdir in _command_roots():
        try:
            children = list(cdir.iterdir())
        except Exception:
            continue
        for p in children:
            if not p.is_file():
                continue
            if os.access(p, os.X_OK) or p.suffix in [".sh", ".py", ".js", ".rb", ".bash"]:
                if is_allowed_script(p):
                    discovered.append(parse_frontmatter(p))
    return discovered


def execute_command(script_path, args=None):
    if args is None:
        args = []
    # Sanitize args to strings only (no nested shell)
    clean_args = [str(a) for a in args]

    try:
        path = Path(script_path).expanduser()
    except Exception:
        return {"status": "error", "error": "Invalid script path"}

    if not is_allowed_script(path):
        return {
            "status": "error",
            "error": "Blocked: script must live under Omnicast commands directories",
        }

    resolved = path.resolve()
    try:
        if not os.access(resolved, os.X_OK):
            interp = INTERPRETERS.get(resolved.suffix.lower())
            if not interp:
                return {"status": "error", "error": "Script is not executable"}
            cmd = interp + [str(resolved)] + clean_args
        else:
            # Executable file under allowlist only — never /bin/bash as the "script"
            cmd = [str(resolved)] + clean_args

        res = subprocess.run(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=15,
            cwd=str(resolved.parent),
        )
        stdout = res.stdout.strip()
        stderr = res.stderr.strip()

        is_json = False
        parsed_json = None
        if (stdout.startswith("{") and stdout.endswith("}")) or (
            stdout.startswith("[") and stdout.endswith("]")
        ):
            try:
                parsed_json = json.loads(stdout)
                is_json = True
            except Exception:
                pass

        return {
            "status": "success" if res.returncode == 0 else "error",
            "returncode": res.returncode,
            "stdout": stdout,
            "stderr": stderr,
            "is_json": is_json,
            "data": parsed_json,
        }
    except Exception as e:
        return {"status": "exception", "error": str(e)}


if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] == "scan":
        from path_safety import write_secure_json, cache_dir

        cmds = scan_commands()
        cache_file = cache_dir() / "script-commands.json"
        write_secure_json(cache_file, cmds)
        print(json.dumps({"ok": True, "count": len(cmds), "path": str(cache_file)}))
    elif sys.argv[1] == "exec" and len(sys.argv) > 2:
        script = sys.argv[2]
        script_args = sys.argv[3:]
        print(json.dumps(execute_command(script, script_args)))
    else:
        print(json.dumps({"status": "error", "error": "usage: scan | exec <script> [args…]"}))
        sys.exit(2)
