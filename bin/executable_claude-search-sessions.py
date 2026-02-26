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
YELLOW_BG = "\033[30;43m"
RESET = "\033[0m"

UUID_RE = re.compile(r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")


# ---------------------------------------------------------------------------
# JSONL / message helpers
# ---------------------------------------------------------------------------

def _read_jsonl(path):
    """Yield parsed JSON objects from a JSONL file, skipping invalid lines."""
    with open(path) as f:
        for line in f:
            try:
                yield json.loads(line)
            except json.JSONDecodeError:
                continue


def _is_user_typed_entry(obj):
    """Return True if a JSONL entry represents genuine user-typed input.

    Excludes:
    - isMeta entries (skill injections, system context)
    - Non-user roles
    - Messages containing tool_result blocks (tool execution responses
      where accompanying text blocks are system-injected context)
    """
    if obj.get("isMeta"):
        return False
    msg = obj.get("message", {})
    if msg.get("role") != "user":
        return False
    content = msg.get("content", "")
    if not isinstance(content, list):
        return True
    return not any(
        isinstance(b, dict) and b.get("type") == "tool_result"
        for b in content
    )


def _iter_user_text(obj):
    """Yield text strings from a user-typed JSONL entry's content."""
    content = obj.get("message", {}).get("content", "")
    if isinstance(content, str):
        yield content
    elif isinstance(content, list):
        for block in content:
            if isinstance(block, dict) and isinstance(block.get("text"), str):
                yield block["text"]


def _extract_text_blocks(message):
    """Yield (role, text) pairs from a message's content field."""
    role = message.get("role", "")
    content = message.get("content", "")
    if isinstance(content, str):
        yield role, content
    elif isinstance(content, list):
        for block in content:
            if isinstance(block, dict) and isinstance(block.get("text"), str):
                yield role, block["text"]


# ---------------------------------------------------------------------------
# Content search
# ---------------------------------------------------------------------------

def _has_user_message_match(session_file, query_lower):
    """Check if any user-typed message in the session contains the query."""
    try:
        for obj in _read_jsonl(session_file):
            if not _is_user_typed_entry(obj):
                continue
            for text in _iter_user_text(obj):
                if query_lower in text.lower():
                    return True
    except OSError:
        pass
    return False


def _content_search(query, user_only=True):
    """Search session .jsonl files via rg, return set of matching session IDs.

    If user_only is True, post-filter rg results to only include sessions where
    a role=user message contains the query.
    """
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
    query_lower = query.lower()
    for path in result.stdout.splitlines():
        basename = os.path.splitext(os.path.basename(path))[0]
        if not UUID_RE.match(basename):
            continue
        if user_only and not _has_user_message_match(path, query_lower):
            continue
        session_ids.add(basename)
    return session_ids


# ---------------------------------------------------------------------------
# History loading
# ---------------------------------------------------------------------------

def _load_sessions():
    """Load all sessions from history.jsonl, return dict keyed by session ID."""
    sessions = {}
    for obj in _read_jsonl(HISTORY_FILE):
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
        sessions[sid]["last_ts"] = max(sessions[sid]["last_ts"], timestamp)

    return sessions


# ---------------------------------------------------------------------------
# Output formatting
# ---------------------------------------------------------------------------

def _highlight(text, query):
    """Highlight all case-insensitive occurrences of query in text."""
    if not query:
        return text
    pattern = re.compile(re.escape(query), re.IGNORECASE)
    return pattern.sub(lambda m: f"{YELLOW_BG}{m.group()}{RESET}", text)


def _format_session_line(sid, info, tag=""):
    """Format a single session as a tab-separated line for fzf."""
    ts = datetime.fromtimestamp(info["last_ts"] / 1000, tz=LOCAL_TZ)
    date_str = ts.strftime("%Y-%m-%d %H:%M")
    project_name = os.path.basename(info["project"]) if info["project"] else "-"
    prompt_count = len(info["prompts"])
    first_prompt = info["first_prompt"].replace("\n", " ").replace("\t", " ")[:80]
    project_path = info["project"] or ""
    return f"{sid}\t{project_path}\t{date_str}\t{project_name}\t{prompt_count}\t{first_prompt}{tag}"


def _matches_history(query_lower, prompts):
    """Check if query matches any prompt display text."""
    return any(query_lower in p.lower() for p in prompts)


def _extract_content_snippets(session_file, query, max_lines=10):
    """Extract matching content snippets from a session file."""
    snippets = []
    query_lower = query.lower()
    try:
        for obj in _read_jsonl(session_file):
            for role, text in _extract_text_blocks(obj.get("message", {})):
                if query_lower not in text.lower():
                    continue
                truncated = text.replace("\n", " ")[:120]
                highlighted = _highlight(truncated, query)
                snippets.append(f"  {DIM}[{role}]{RESET} {highlighted}")
                if len(snippets) >= max_lines:
                    return snippets
    except OSError:
        pass
    return snippets


def _find_session_file(session_id):
    """Find the session .jsonl file across project directories."""
    for dirpath, _, filenames in os.walk(PROJECTS_DIR):
        fname = f"{session_id}.jsonl"
        if fname in filenames:
            return os.path.join(dirpath, fname)
    return None


# ---------------------------------------------------------------------------
# Entry points
# ---------------------------------------------------------------------------

def parse_history(query=None, cwd=None, search_mode="user"):
    sessions = _load_sessions()
    user_only = search_mode == "user"
    content_match_ids = _content_search(query, user_only=user_only) if query else set()
    query_lower = query.lower() if query else ""

    sorted_sessions = sorted(
        sessions.items(), key=lambda x: x[1]["last_ts"], reverse=True
    )

    for sid, info in sorted_sessions:
        history_match = _matches_history(query_lower, info["prompts"]) if query else False
        content_match = sid in content_match_ids

        if query and not history_match and not content_match:
            continue

        tag = " [content]" if query and content_match and not history_match else ""
        line = _format_session_line(sid, info, tag)

        if cwd and (info["project"] or "") == cwd:
            print(f"{GREEN}{line}{RESET}")
        else:
            print(line)

    # Content-only sessions not in history (session file exists but no history entry)
    if query:
        known_ids = set(sessions)
        for sid in sorted(content_match_ids - known_ids):
            line = f"{sid}\t\t-\t-\t0\t[content match only]"
            print(f"{DIM}{line}{RESET}")


def show_session_prompts(session_id, query=None):
    """Output all prompts for a given session (used for fzf preview)."""
    for obj in _read_jsonl(HISTORY_FILE):
        if obj.get("sessionId") != session_id:
            continue

        timestamp = obj.get("timestamp", 0)
        ts = datetime.fromtimestamp(timestamp / 1000, tz=LOCAL_TZ)
        date_str = ts.strftime("%m-%d %H:%M")
        text = obj.get("display", "").replace("\n", " ")[:120]
        print(f"  {date_str}  {_highlight(text, query)}")

    if not query:
        return
    session_file = _find_session_file(session_id)
    if not session_file:
        return
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
        parser.add_argument(
            "--search-mode",
            choices=["user", "all"],
            default="user",
            help="user: match only user messages, all: match entire session",
        )
        args = parser.parse_args()
        parse_history(args.query, args.cwd, search_mode=args.search_mode)
