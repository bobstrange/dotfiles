#!/usr/bin/env python3
"""Parse ~/.claude/history.jsonl and output session list for fzf integration."""

import json
import os
import signal
import sys
from datetime import datetime, timezone, timedelta

signal.signal(signal.SIGPIPE, signal.SIG_DFL)

LOCAL_TZ = timezone(timedelta(hours=9))
HISTORY_FILE = os.path.expanduser("~/.claude/history.jsonl")


def parse_history(query=None):
    sessions = {}

    with open(HISTORY_FILE) as f:
        for line in f:
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue

            sid = obj.get("sessionId")
            if not sid:
                continue

            display = obj.get("display", "")
            timestamp = obj.get("timestamp", 0)
            project = obj.get("project", "")

            if sid not in sessions:
                sessions[sid] = {
                    "first_prompt": display,
                    "prompts": [],
                    "first_ts": timestamp,
                    "last_ts": timestamp,
                    "project": project,
                }

            sessions[sid]["prompts"].append(display)
            if timestamp > sessions[sid]["last_ts"]:
                sessions[sid]["last_ts"] = timestamp

    # Sort by last timestamp descending
    sorted_sessions = sorted(
        sessions.items(), key=lambda x: x[1]["last_ts"], reverse=True
    )

    for sid, info in sorted_sessions:
        # Apply query filter across all prompts
        if query:
            match = any(query.lower() in p.lower() for p in info["prompts"])
            if not match:
                continue

        ts = datetime.fromtimestamp(info["last_ts"] / 1000, tz=LOCAL_TZ)
        date_str = ts.strftime("%Y-%m-%d %H:%M")
        project_name = os.path.basename(info["project"]) if info["project"] else "-"
        prompt_count = len(info["prompts"])
        first_prompt = info["first_prompt"].replace("\n", " ").replace("\t", " ")[:80]

        project_path = info["project"] or ""
        print(
            f"{sid}\t{project_path}\t{date_str}\t{project_name}\t{prompt_count}\t{first_prompt}"
        )


def show_session_prompts(session_id):
    """Output all prompts for a given session (used for fzf preview)."""
    with open(HISTORY_FILE) as f:
        for line in f:
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue

            if obj.get("sessionId") != session_id:
                continue

            display = obj.get("display", "")
            timestamp = obj.get("timestamp", 0)
            ts = datetime.fromtimestamp(timestamp / 1000, tz=LOCAL_TZ)
            date_str = ts.strftime("%m-%d %H:%M")
            text = display.replace("\n", " ")[:120]
            print(f"  {date_str}  {text}")


if __name__ == "__main__":
    if len(sys.argv) >= 2 and sys.argv[1] == "--preview":
        show_session_prompts(sys.argv[2])
    else:
        query = sys.argv[1] if len(sys.argv) >= 2 else None
        parse_history(query)
