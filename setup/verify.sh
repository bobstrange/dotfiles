#!/usr/bin/env bash
# Report drift between this repo and the machine it is installed on.
#
# CI only ever renders templates from a fresh checkout, so it cannot see either
# way a real machine rots:
#
#   $HOME differs from source   an app rewrote its own config behind chezmoi's
#                               back (zed and VS Code settings.json are managed
#                               with an explicit "edit the target, then
#                               `chezmoi add`" workflow, so a missed add is a
#                               normal outcome, not a mistake)
#   source is uncommitted       a `chezmoi add` landed but was never committed,
#                               so the change exists on exactly one machine
#
# Both are silent until a reinstall, which is when they are most expensive.
# Exits non-zero when either is found, so this can be promoted to a hook later.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

section() {
  printf '\n==> %s\n' "$1"
}

indent() {
  sed 's/^/    /'
}

status=0

section "Targets in \$HOME vs the chezmoi source"
if [ ! -f "$HOME/.config/chezmoi/key.txt" ]; then
  # Same reason CI passes --exclude encrypted: without the age identity these
  # cannot be decrypted, and chezmoi would report every one of them as drift.
  printf '    note: age key absent, encrypted files not checked\n'
  drift="$(chezmoi status --exclude=encrypted)"
else
  drift="$(chezmoi status)"
fi

if [ -n "$drift" ]; then
  printf '%s\n' "$drift" | indent
  printf '\n'
  printf '    Second column is the target: M = the installed file has drifted.\n'
  printf '    Inspect        : chezmoi diff <path>\n'
  printf '    Keep installed : chezmoi add <path>\n'
  printf '    Keep source    : chezmoi apply <path>\n'
  status=1
else
  printf '    no drift\n'
fi

section "Uncommitted changes in the chezmoi source"
repo_status="$(git -C "$REPO_DIR" status --porcelain)"
if [ -n "$repo_status" ]; then
  printf '%s\n' "$repo_status" | indent
  printf '\n'
  printf '    These exist on this machine only until they are committed.\n'
  status=1
else
  printf '    clean\n'
fi

exit "$status"
