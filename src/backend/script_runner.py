#!/usr/bin/env python3
import os
import sys
import json
import re
import subprocess
from pathlib import Path

COMMAND_DIRS = [
    Path.home() / ".config/omnicast/commands",
    Path(__file__).parent.parent / "commands"
]

def parse_frontmatter(file_path):
    metadata = {
        "id": f"cmd-{file_path.stem}",
        "path": str(file_path.resolve()),
        "title": file_path.stem.replace("-", " ").title(),
        "subtitle": f"Script Command • {file_path.name}",
        "mode": "fullOutput",
        "icon": "⚡",
        "category": "Script Commands",
        "badge": "Script",
        "arguments": []
    }
    
    try:
        with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
            lines = f.readlines()
            
        for line in lines[:40]: # Only parse header
            line = line.strip()
            # Match @omarchy.key or @raycast.key
            m = re.match(r"^#\s*@(omarchy|raycast)\.([a-zA-Z0-9_]+)\s+(.+)$", line)
            if m:
                key = m.group(2)
                val = m.group(3).strip()
                
                if key == "title":
                    metadata["title"] = val
                elif key == "mode":
                    metadata["mode"] = val # fullOutput, compact, silent, inline
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
                    except:
                        metadata["arguments"].append({"type": "text", "placeholder": val, "name": f"arg{len(metadata['arguments'])+1}"})
    except Exception as e:
        print(f"Error parsing {file_path}: {e}", file=sys.stderr)
        
    return metadata

def scan_commands():
    discovered = []
    for cdir in COMMAND_DIRS:
        if not cdir.exists():
            cdir.mkdir(parents=True, exist_ok=True)
            continue
            
        for p in cdir.iterdir():
            if p.is_file() and (os.access(p, os.X_OK) or p.suffix in [".sh", ".py", ".js", ".rb"]):
                cmd_meta = parse_frontmatter(p)
                discovered.append(cmd_meta)
                
    return discovered

def execute_command(script_path, args=None):
    if args is None:
        args = []
        
    try:
        # If not directly executable, pick interpreter
        cmd = [script_path] + args
        if not os.access(script_path, os.X_OK):
            if script_path.endswith(".py"):
                cmd = ["python3", script_path] + args
            elif script_path.endswith(".sh"):
                cmd = ["bash", script_path] + args
            elif script_path.endswith(".js"):
                cmd = ["node", script_path] + args
                
        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=15)
        stdout = res.stdout.strip()
        stderr = res.stderr.strip()
        
        # Check if output is JSON
        is_json = False
        parsed_json = None
        if (stdout.startswith("{") and stdout.endswith("}")) or (stdout.startswith("[") and stdout.endswith("]")):
            try:
                parsed_json = json.loads(stdout)
                is_json = True
            except:
                pass
                
        return {
            "status": "success" if res.returncode == 0 else "error",
            "returncode": res.returncode,
            "stdout": stdout,
            "stderr": stderr,
            "is_json": is_json,
            "data": parsed_json
        }
    except Exception as e:
        return {
            "status": "exception",
            "error": str(e)
        }

if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] == "scan":
        print(json.dumps(scan_commands()))
    elif sys.argv[1] == "exec" and len(sys.argv) > 2:
        script = sys.argv[2]
        script_args = sys.argv[3:]
        print(json.dumps(execute_command(script, script_args)))
