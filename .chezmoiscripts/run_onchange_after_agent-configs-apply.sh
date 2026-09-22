#!/bin/bash
# Compose ~/.claude from the coding-agent-configs layers (chezmoi ignores
# .claude; see README "Claude Code config"). Re-runs only when this file
# changes; day to day, `agent-configs apply` is run by hand and the
# SessionStart `doctor` hook reports drift. Never fails chezmoi apply: a
# missing clone or a conflict is a hint, not an error.
repo="$(ghq root 2>/dev/null || printf '%s/src' "$HOME")/github.com/bobstrange/coding-agent-configs"
cli="$repo/bin/agent-configs"
if [ ! -x "$cli" ]; then
  echo "agent-configs: no clone at $repo — see README 'Claude Code config'; ~/.claude left as is"
  exit 0
fi
if ! "$cli" apply; then
  echo "agent-configs apply reported conflicts; review with 'agent-configs apply --dry-run' and re-run with --force"
fi
exit 0
