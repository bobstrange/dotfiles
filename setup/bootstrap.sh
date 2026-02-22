#!/bin/bash
set -euo pipefail

# Bootstrap script for setting up a new machine from scratch.
# Usage: curl -fsLS https://raw.githubusercontent.com/bobstrange/dotfiles/main/setup/bootstrap.sh | bash

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

# --- Init chezmoi (clone dotfiles repo) ---
if [ -d "$CHEZMOI_DIR/.git" ]; then
  info "Dotfiles repo already exists at $CHEZMOI_DIR"
else
  info "Cloning dotfiles via chezmoi init..."
  "$CHEZMOI_BIN" init bobstrange
fi

cd "$CHEZMOI_DIR"

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

  info "Running make setup-macos..."
  make setup-macos

  if [ ! -f "$HOME/.config/chezmoi/key.txt" ]; then
    info "WARNING: age key not found at ~/.config/chezmoi/key.txt"
    info "Encrypted files (e.g. SSH config) will be skipped."
    info "Restore the key from 1Password, then run: chezmoi apply"
    "$CHEZMOI_BIN" apply --exclude=encrypted
  else
    info "Applying dotfiles..."
    "$CHEZMOI_BIN" apply
  fi

  echo ""
  info "Setup complete!"
  echo ""
  echo "Next steps:"
  echo "  1. Restart your shell"
  echo "  2. Restore age key from 1Password: mkdir -p ~/.config/chezmoi && vim ~/.config/chezmoi/key.txt"
  echo "  3. Run 'chezmoi apply' to decrypt encrypted files"
  echo "  4. After setting up Dropbox: make symlinks"

elif [ "$PLATFORM" = "linux" ]; then
  info "Running make setup-nix..."
  make setup-nix

  # Source Nix for current session (instead of restarting shell)
  if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    # shellcheck disable=SC1091
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  fi

  info "Running make setup-linux..."
  make setup-linux

  if [ ! -f "$HOME/.config/chezmoi/key.txt" ]; then
    info "WARNING: age key not found at ~/.config/chezmoi/key.txt"
    info "Encrypted files (e.g. SSH config) will be skipped."
    info "Restore the key from 1Password, then run: chezmoi apply"
    "$CHEZMOI_BIN" apply --exclude=encrypted
  else
    info "Applying dotfiles..."
    "$CHEZMOI_BIN" apply
  fi

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
