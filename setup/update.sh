#!/usr/bin/env bash
# Update everything this repo installs but never moves on its own.
#
# The plugin managers here bootstrap with "clone if absent" (tpm) or run_once_
# (gh extensions), and mise resolves latest/lts only at install time. Nothing
# re-checks afterwards, so without a periodic sweep these silently rot until
# something breaks.
#
# Nix is deliberately absent: CI owns nix/flake.lock (weekly PR, verified by
# `nix build`), and updating it here would trip setup/check-lock-drift.sh.
# Pull an update in with `git pull && make nix-apply` instead.
set -euo pipefail

section() {
  printf '\n==> %s\n' "$1"
}

skip() {
  printf '    skipped: %s\n' "$1"
}

section "Neovim plugins (lazy.nvim)"
if command -v nvim >/dev/null 2>&1; then
  nvim --headless "+Lazy! sync" +qa
else
  skip "nvim not installed"
fi

section "tmux plugins (tpm)"
if [ -x "$HOME/.tmux/plugins/tpm/bin/update_plugins" ]; then
  # tpm has no self-update path: plugins.conf only clones it when absent.
  git -C "$HOME/.tmux/plugins/tpm" pull --ff-only
  "$HOME/.tmux/plugins/tpm/bin/update_plugins" all
else
  skip "tpm not installed (start tmux once to bootstrap it)"
fi

section "gh extensions"
if command -v gh >/dev/null 2>&1; then
  gh extension upgrade --all
else
  skip "gh not installed"
fi

section "Language runtimes (mise)"
if command -v mise >/dev/null 2>&1; then
  # Stays within the config's spec: latest/lts re-resolve, erlang = "28" stays 28.x.
  mise upgrade
else
  skip "mise not installed"
fi

if [ "$(uname -s)" = "Darwin" ]; then
  section "Homebrew packages"
  brew update
  brew upgrade
fi

printf '\n==> Nix packages\n'
printf '    not updated here — CI owns nix/flake.lock.\n'
printf '    Run: git pull && make nix-apply\n'

if [ "$(uname -s)" = "Linux" ]; then
  printf '\n==> APT packages\n'
  printf '    not updated here — use the apt-update alias (needs sudo).\n'
fi
