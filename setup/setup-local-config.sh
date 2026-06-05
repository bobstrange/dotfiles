#!/bin/bash
# Configure ~/.config/chezmoi/chezmoi.toml for this machine.
# Controls which dotfiles are applied via chezmoi data variables.
#
# Variables:
#   work = true  — skip dot_claude/ (managed separately via agent-configs symlinks)

set -euo pipefail

CHEZMOI_CONFIG="$HOME/.config/chezmoi/chezmoi.toml"

usage() {
  echo "Usage: $0 [--work | --personal]"
  echo ""
  echo "  --work       Work machine: dot_claude/ managed by agent-configs symlinks"
  echo "  --personal   Personal machine: dot_claude/ managed by chezmoi (default)"
  exit 1
}

# Parse argument or prompt interactively
if [ $# -eq 1 ]; then
  case "$1" in
    --work)     machine_type="work" ;;
    --personal) machine_type="personal" ;;
    *) usage ;;
  esac
else
  echo "What type of machine is this?"
  echo "  1) Personal (dot_claude/ managed by chezmoi)"
  echo "  2) Work     (dot_claude/ managed by agent-configs symlinks)"
  read -rp "Choice [1/2]: " choice
  case "$choice" in
    1) machine_type="personal" ;;
    2) machine_type="work" ;;
    *) echo "Invalid choice"; exit 1 ;;
  esac
fi

mkdir -p "$(dirname "$CHEZMOI_CONFIG")"

if [ "$machine_type" = "work" ]; then
  cat > "$CHEZMOI_CONFIG" <<'TOML'
[data]
  work = true
TOML
  echo "Wrote $CHEZMOI_CONFIG (work=true)"
  echo "dot_claude/ will be skipped by chezmoi apply."
else
  # Remove work flag if present, or write minimal config
  if [ -f "$CHEZMOI_CONFIG" ] && grep -q 'work = true' "$CHEZMOI_CONFIG"; then
    # Remove the work = true line
    tmp=$(mktemp)
    grep -v 'work = true' "$CHEZMOI_CONFIG" > "$tmp"
    mv "$tmp" "$CHEZMOI_CONFIG"
    echo "Removed work=true from $CHEZMOI_CONFIG"
  else
    echo "No changes needed ($CHEZMOI_CONFIG already set for personal use)."
  fi
  echo "dot_claude/ will be managed by chezmoi."
fi
