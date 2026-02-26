#!/usr/bin/env python3
"""Parse ~/.claude/history.jsonl and session files for fzf integration.

Supports two search modes:
- History search: filter by display text in history.jsonl (always)
- Content search: grep session .jsonl files via rg (when query provided)
"""

import json
import os
import re
import signal
import subprocess
import sys
from datetime import datetime, timezone, timedelta

signal.signal(signal.SIGPIPE, signal.SIG_DFL)

LOCAL_TZ = timezone(timedelta(hours=9))
HISTORY_FILE = os.path.expanduser("~/.claude/history.jsonl")
PROJECTS_DIR = os.path.expanduser("~/.claude/projects")

GREEN = "\033[32m"
CYAN = "\033[36m"
DIM = "\033[2m"
RESET = "\033[0m"

UUID_RE = re.compile(r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")


def _content_search(query):
    """Search session .jsonl files via rg, return set of matching session IDs."""
    try:
        result = subprocess.run(
            ["rg", "-Fil", "--glob", "*.jsonl", query, PROJECTS_DIR],
            capture_output=True,
            text=True,
            timeout=30,
        )
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return set()

    session_ids = set()
    for path in result.stdout.splitlines():
        basename = os.path.splitext(os.path.basename(path))[0]
        if UUID_RE.match(basename):
            session_ids.add(basename)
    return session_ids


def parse_history(query=None, cwd=None):
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

    # Content search: find session IDs matching query in conversation files
    content_match_ids = set()
    if query:
        content_match_ids = _content_search(query)

    # Sort by last timestamp descending
    sorted_sessions = sorted(
        sessions.items(), key=lambda x: x[1]["last_ts"], reverse=True
    )

    # Track history-matched session IDs for content-only detection
    history_match_ids = set()

    for sid, info in sorted_sessions:
        history_match = False
        content_match = sid in content_match_ids

        if query:
            history_match = any(query.lower() in p.lower() for p in info["prompts"])
            if not history_match and not content_match:
                continue
            if history_match:
                history_match_ids.add(sid)

        ts = datetime.fromtimestamp(info["last_ts"] / 1000, tz=LOCAL_TZ)
        date_str = ts.strftime("%Y-%m-%d %H:%M")
        project_name = os.path.basename(info["project"]) if info["project"] else "-"
        prompt_count = len(info["prompts"])
        first_prompt = info["first_prompt"].replace("\n", " ").replace("\t", " ")[:80]

        # Mark content-only matches
        tag = ""
        if query and content_match and not history_match:
            tag = " [content]"

        project_path = info["project"] or ""
        line = f"{sid}\t{project_path}\t{date_str}\t{project_name}\t{prompt_count}\t{first_prompt}{tag}"
        if cwd and project_path == cwd:
            print(f"{GREEN}{line}{RESET}")
        else:
            print(line)

    # Content-only sessions not in history (edge case: session file exists but no history entry)
    if query:
        shown_ids = {sid for sid, _ in sorted_sessions}
        for sid in sorted(content_match_ids - shown_ids):
            # Try to get timestamp from session file
            line = f"{sid}\t\t-\t-\t0\t[content match only]"
            print(f"{DIM}{line}{RESET}")


def _extract_content_snippets(session_file, query, max_lines=10):
    """Extract matching content snippets from a session file."""
    snippets = []
    query_lower = query.lower()
    try:
        with open(session_file) as f:
            for line in f:
                try:
                    obj = json.loads(line)
                except json.JSONDecodeError:
                    continue

                msg_type = obj.get("type", "")
                # Look in message content
                message = obj.get("message", {})
                content = message.get("content", "")
                role = message.get("role", "")

                if isinstance(content, str) and query_lower in content.lower():
                    text = content.replace("\n", " ")[:120]
                    snippets.append(f"  {DIM}[{role}]{RESET} {text}")
                elif isinstance(content, list):
                    for block in content:
                        if isinstance(block, dict):
                            text_val = block.get("text", "")
                            if isinstance(text_val, str) and query_lower in text_val.lower():
                                text = text_val.replace("\n", " ")[:120]
                                snippets.append(f"  {DIM}[{role}]{RESET} {text}")

                if len(snippets) >= max_lines:
                    break
    except (OSError, json.JSONDecodeError):
        pass
    return snippets


def _find_session_file(session_id):
    """Find the session .jsonl file across project directories."""
    for dirpath, _, filenames in os.walk(PROJECTS_DIR):
        fname = f"{session_id}.jsonl"
        if fname in filenames:
            return os.path.join(dirpath, fname)
    return None


def show_session_prompts(session_id, query=None):
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

    # Show content matches if query provided
    if query:
        session_file = _find_session_file(session_id)
        if session_file:
            snippets = _extract_content_snippets(session_file, query)
            if snippets:
                print(f"\n{CYAN}--- Content matches ---{RESET}")
                for s in snippets:
                    print(s)


if __name__ == "__main__":
    if len(sys.argv) >= 2 and sys.argv[1] == "--preview":
        session_id = sys.argv[2] if len(sys.argv) > 2 else ""
        query = sys.argv[3] if len(sys.argv) > 3 else None
        show_session_prompts(session_id, query)
    else:
        import argparse

        parser = argparse.ArgumentParser()
        parser.add_argument("query", nargs="?", default=None)
        parser.add_argument("--cwd", default=None)
        args = parser.parse_args()
        parse_history(args.query, args.cwd)
