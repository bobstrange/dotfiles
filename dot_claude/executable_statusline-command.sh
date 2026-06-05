#!/bin/bash
# Claude Code status line

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0' | cut -d. -f1)
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
transcript=$(echo "$input" | jq -r '.transcript_path // empty')

# Compute used tokens
used_tokens=0
if [ "$ctx_size" -gt 0 ] 2>/dev/null && [ "$used_pct" -gt 0 ] 2>/dev/null; then
  used_tokens=$((used_pct * ctx_size / 100))
fi

# Shorten path
home_dir=$(eval echo "~")
short_cwd="${cwd/#$home_dir/\~}"

# Git branch
git_branch=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
fi

# Context color (token-based)
if [ "$used_tokens" -le 120000 ]; then
  ctx_color='\033[32m'
elif [ "$used_tokens" -le 150000 ]; then
  ctx_color='\033[33m'
else
  ctx_color='\033[31m'
fi

# Turn count
turn_count=0
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  turn_count=$(grep -c '"type":"user"' "$transcript" 2>/dev/null || echo 0)
fi

# --- Rate limits ---
# 5h: read directly from native statusline JSON
five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' | cut -d. -f1)

# 7d: call OAuth usage API (cached, macOS Keychain or credentials file)
USAGE_CACHE="${TMPDIR:-/tmp}/claude-usage-cache.json"
USAGE_CACHE_MAX_AGE=180

file_mtime() {
  if [ "$(uname)" = "Darwin" ]; then
    stat -f %m "$1" 2>/dev/null || echo 0
  else
    stat -c %Y "$1" 2>/dev/null || echo 0
  fi
}

usage_cache_is_stale() {
  [ ! -f "$USAGE_CACHE" ] || \
  [ $(( $(date +%s) - $(file_mtime "$USAGE_CACHE") )) -gt $USAGE_CACHE_MAX_AGE ]
}

get_access_token() {
  # macOS Keychain
  if [ "$(uname)" = "Darwin" ]; then
    token=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null \
      | jq -r '.accessToken // empty' 2>/dev/null)
    [ -n "$token" ] && echo "$token" && return
  fi
  # Fallback: credentials file (Linux)
  local creds="$HOME/.claude/.credentials.json"
  if [ -f "$creds" ]; then
    jq -r '.claudeAiOauth.accessToken // empty' "$creds" 2>/dev/null
  fi
}

weekly_pct=""
if usage_cache_is_stale; then
  access_token=$(get_access_token)
  if [ -n "$access_token" ]; then
    curl -s --max-time 3 \
      -H "Authorization: Bearer $access_token" \
      -H "anthropic-beta: oauth-2025-04-20" \
      -H "User-Agent: claude-code/2" \
      "https://api.anthropic.com/api/oauth/usage" > "$USAGE_CACHE" 2>/dev/null || true
  fi
fi
if [ -f "$USAGE_CACHE" ]; then
  weekly_pct=$(jq -r '.seven_day.utilization // empty' "$USAGE_CACHE" 2>/dev/null | cut -d. -f1)
fi

# Color helper for usage %
usage_color() {
  local pct="$1"
  if [ "$pct" -le 60 ] 2>/dev/null; then
    printf '\033[32m'
  elif [ "$pct" -le 90 ] 2>/dev/null; then
    printf '\033[33m'
  else
    printf '\033[31m'
  fi
}

# Build status line
parts="\033[34m${short_cwd}\033[0m"

[ -n "$git_branch" ] && parts="${parts} \033[35m${git_branch}\033[0m"

parts="${parts} \033[2m${model}\033[0m"
parts="${parts} \033[2mturn:${turn_count}\033[0m"
parts="${parts} ${ctx_color}ctx:${used_pct}%\033[0m"

if [ -n "$five_hour_pct" ]; then
  c=$(usage_color "$five_hour_pct")
  parts="${parts} ${c}5h:${five_hour_pct}%\033[0m"
fi
if [ -n "$weekly_pct" ]; then
  c=$(usage_color "$weekly_pct")
  parts="${parts} ${c}7d:${weekly_pct}%\033[0m"
fi

if [ "$(echo "$cost > 0" | bc -l 2>/dev/null)" = "1" ]; then
  parts="${parts} \033[2m\$$(printf '%.2f' "$cost")\033[0m"
fi

echo -e "$parts"
