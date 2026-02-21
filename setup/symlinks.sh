#!/bin/bash
# Symlink secret files from Dropbox

set -euo pipefail

DROPBOX="$HOME/Dropbox/config"

if [ ! -d "$DROPBOX" ]; then
  echo "Error: Dropbox config directory not found: $DROPBOX"
  exit 1
fi

symlink() {
  local src="$1"
  local dest="$2"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "Warning: $dest already exists and is not a symlink, skipping"
    return
  fi
  ln -sfn "$src" "$dest"
  echo "Linked: $dest -> $src"
}

# SSH
symlink "$DROPBOX/.ssh" "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
chmod 600 "$HOME/.ssh/id_rsa" 2>/dev/null || true
chmod 644 "$HOME/.ssh/id_rsa.pub" "$HOME/.ssh/known_hosts" "$HOME/.ssh/config" 2>/dev/null || true

# AWS
symlink "$DROPBOX/aws" "$HOME/.aws"
chmod 755 "$HOME/.aws"

# Tokens
symlink "$DROPBOX/github_token" "$HOME/.github_token"
symlink "$DROPBOX/dockerhub_token" "$HOME/.dockerhub_token"

echo "Done."
