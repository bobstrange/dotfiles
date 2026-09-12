#!/bin/bash
set -euo pipefail

# Bootstrap script for setting up a new machine from scratch.
# Usage: curl -fsLS https://raw.githubusercontent.com/bobstrange/dotfiles/main/setup/bootstrap.sh | bash
#
# Verified end to end by `make bootstrap-test` (setup/test-bootstrap.sh), which
# runs this in a fresh Ubuntu container. Keep the two in step.

CHEZMOI_BIN="$HOME/.local/bin/chezmoi"
CHEZMOI_DIR="$HOME/.local/share/chezmoi"

info() { echo "==> $*"; }
error() { echo "ERROR: $*" >&2; exit 1; }

# --- Detect OS ---
OS="$(uname -s)"
case "$OS" in
  Darwin) PLATFORM="macos" ;;
  Linux)  PLATFORM="linux" ;;
  *)      error "Unsupported OS: $OS" ;;
esac

info "Detected platform: $PLATFORM"

# --- Install chezmoi ---
if [ -x "$CHEZMOI_BIN" ]; then
  info "chezmoi already installed"
else
  info "Installing chezmoi..."
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
fi

# --- Init chezmoi ---
# Always run it: init clones the repo when it is absent, and when it is already
# there (a manual clone, or a re-run) it still (re)generates
# ~/.config/chezmoi/chezmoi.toml from .chezmoi.toml.tmpl, which `chezmoi apply`
# needs for the age settings. Skipping it on an existing checkout left that
# file missing.
if [ -d "$CHEZMOI_DIR/.git" ]; then
  info "Dotfiles repo already exists at $CHEZMOI_DIR; regenerating chezmoi config"
else
  info "Cloning dotfiles via chezmoi init..."
fi
"$CHEZMOI_BIN" init bobstrange

cd "$CHEZMOI_DIR"

# --- Apply dotfiles ---
# Before `make setup-*`, not after: mise reads ~/.config/mise/config.toml, so
# `mise install` on an unapplied machine installs nothing (and exits 0), and
# lefthook-setup then finds no node. apply itself needs nothing from nix — the
# run_once_ scripts guard on `command -v`.
apply_dotfiles() {
  if [ ! -f "$HOME/.config/chezmoi/key.txt" ]; then
    info "WARNING: age key not found at ~/.config/chezmoi/key.txt"
    info "Encrypted files (e.g. SSH config) will be skipped."
    info "Restore the key from 1Password, then run: chezmoi apply"
    "$CHEZMOI_BIN" apply --exclude=encrypted
  else
    info "Applying dotfiles..."
    "$CHEZMOI_BIN" apply
  fi
}

# --- Platform-specific setup ---
if [ "$PLATFORM" = "macos" ]; then
  # Install Homebrew if missing
  if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Source Homebrew for current session
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    info "Homebrew already installed"
  fi

  apply_dotfiles

  info "Running make setup-macos..."
  make setup-macos

  echo ""
  info "Setup complete!"
  echo ""
  echo "Next steps:"
  echo "  1. Restart your shell"
  echo "  2. Restore age key from 1Password: mkdir -p ~/.config/chezmoi && vim ~/.config/chezmoi/key.txt"
  echo "  3. Run 'chezmoi apply' to decrypt encrypted files"
  echo "  4. After setting up Dropbox: make symlinks"

elif [ "$PLATFORM" = "linux" ]; then
  if ! command -v make >/dev/null 2>&1; then
    info "Installing make..."
    sudo apt-get install -y make
  fi

  # Which `make setup-*` to run. Auto-detected from WSL, overridable so the
  # smoke test can pin the target it asserts on (a container is not WSL, and
  # setup-linux needs a GNOME session).
  if [ -z "${DOTFILES_SETUP_TARGET:-}" ]; then
    if grep -qi microsoft /proc/version 2>/dev/null; then
      DOTFILES_SETUP_TARGET=setup-wsl
    else
      DOTFILES_SETUP_TARGET=setup-linux
    fi
  fi
  case "$DOTFILES_SETUP_TARGET" in
    setup-linux|setup-wsl) ;;
    *) error "DOTFILES_SETUP_TARGET must be setup-linux or setup-wsl, got: $DOTFILES_SETUP_TARGET" ;;
  esac

  apply_dotfiles

  info "Running make setup-nix..."
  make setup-nix

  # Source Nix for current session (instead of restarting shell)
  if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    # shellcheck disable=SC1091
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  fi

  if [ "$DOTFILES_SETUP_TARGET" = "setup-wsl" ]; then
    info "Skipping GNOME/xremap setup"
  fi
  info "Running make $DOTFILES_SETUP_TARGET..."
  make "$DOTFILES_SETUP_TARGET"

  echo ""
  info "Setup complete!"
  echo ""
  echo "Next steps:"
  echo "  1. Restore age key from 1Password: mkdir -p ~/.config/chezmoi && vim ~/.config/chezmoi/key.txt"
  echo "  2. Run 'chezmoi apply' to decrypt encrypted files"
  echo "  3. If added to input group: log out and back in for xremap to work"
  echo "  4. After setting up Dropbox: make symlinks"
  echo "  5. Restart your shell"
fi
