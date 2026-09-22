#!/bin/bash
# Configure the machine type for chezmoi (work or personal).
#
# The answer is stored as a marker file, ~/.config/chezmoi/work-machine, which
# .chezmoi.toml.tmpl reads to set the `work` data variable. The marker lives
# outside the generated ~/.config/chezmoi/chezmoi.toml on purpose: that file is
# regenerated from the template by every `chezmoi init`, so anything written
# into it directly (including the encryption settings) would be lost.
#
# Variables:
#   work = true  — no IdentityAgent pin in ~/.ssh/config (see private_dot_ssh/)
#
# ~/.claude is not part of this switch: chezmoi ignores it on every machine
# (see README "Claude Code config").

set -euo pipefail

MARKER="$HOME/.config/chezmoi/work-machine"

usage() {
  echo "Usage: $0 [--work | --personal]"
  echo ""
  echo "  --work       Work machine: no 1Password IdentityAgent pin in ~/.ssh/config"
  echo "  --personal   Personal machine: IdentityAgent pinned (default)"
  exit 1
}

# Parse argument or prompt interactively
if [ $# -eq 1 ]; then
  case "$1" in
    --work)     machine_type="work" ;;
    --personal) machine_type="personal" ;;
    *) usage ;;
  esac
elif [ $# -gt 1 ]; then
  usage
else
  echo "What type of machine is this?"
  echo "  1) Personal (1Password IdentityAgent pinned in ~/.ssh/config)"
  echo "  2) Work     (no IdentityAgent pin)"
  read -rp "Choice [1/2]: " choice
  case "$choice" in
    1) machine_type="personal" ;;
    2) machine_type="work" ;;
    *) echo "Invalid choice"; exit 1 ;;
  esac
fi

mkdir -p "$(dirname "$MARKER")"

if [ "$machine_type" = "work" ]; then
  touch "$MARKER"
  echo "Marked as a work machine ($MARKER)"
  echo "The ssh config will not pin the 1Password IdentityAgent."
else
  rm -f "$MARKER"
  echo "Marked as a personal machine (no $MARKER)"
  echo "The ssh config will pin the 1Password IdentityAgent."
fi

# Regenerate ~/.config/chezmoi/chezmoi.toml so `work` takes effect. Templated
# from .chezmoi.toml.tmpl, so the age encryption settings are preserved.
chezmoi init

echo ""
echo "Run 'chezmoi diff' to review what this changes, then 'chezmoi apply'."
