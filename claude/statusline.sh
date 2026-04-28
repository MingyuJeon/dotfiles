#!/usr/bin/env python3
"""Claude Code statusline: <branch> (*) | NN%

(*) marker appears when the working tree has uncommitted changes
(staged, unstaged, or untracked).
"""
import json
import subprocess
import sys


def git(args, cwd):
    try:
        r = subprocess.run(
            ["git", "-C", cwd, *args],
            capture_output=True, text=True, timeout=2,
        )
        return r.stdout.strip() if r.returncode == 0 else ""
    except Exception:
        return ""


data = json.load(sys.stdin)
cwd = (
    data.get("workspace", {}).get("current_dir")
    or data.get("cwd")
    or "."
)
pct = data.get("context_window", {}).get("used_percentage", 0)

branch = git(["branch", "--show-current"], cwd)
dirty = " (*)" if branch and git(["status", "--porcelain"], cwd) else ""
prefix = branch if branch else "(no git)"

print(f"{prefix}{dirty} | {int(pct)}%")
