# Claude Code session search & resume with fzf
# Usage: csr [query]

_CLAUDE_SESSION_SCRIPT="$HOME/.local/bin/claude-search-sessions.py"

csr() {
  local missing=()
  for cmd in python3 fzf claude; do
    if ! command -v "$cmd" &>/dev/null; then
      missing+=("$cmd")
    fi
  done
  if (( ${#missing[@]} > 0 )); then
    echo "Missing dependencies: ${missing[*]}" >&2
    echo "Install with: nix profile install nixpkgs#{${(j:,:)missing}}" >&2
    return 1
  fi

  local query="${1:-}"
  local selected

  selected=$(
    python3 "$_CLAUDE_SESSION_SCRIPT" --cwd "$PWD" |
      fzf \
        --query="$query" \
        --delimiter='\t' \
        --with-nth='3..' \
        --header='date        project         #  first prompt' \
        --preview="python3 $_CLAUDE_SESSION_SCRIPT --preview {1}" \
        --preview-window='down:40%:wrap' \
        --no-sort \
        --ansi
  )

  if [[ -n "$selected" ]]; then
    local session_id project_path
    session_id=$(echo "$selected" | cut -f1)
    project_path=$(echo "$selected" | cut -f2)
    echo "Resuming session: $session_id (${project_path})"
    (cd "$project_path" && claude --resume "$session_id")
  fi
}
