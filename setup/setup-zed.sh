#!/bin/bash
set -euo pipefail

# Install Zed into ~/.local with its official script; Zed self-updates afterwards.
# Not nix: off NixOS its zed-editor lacks host GPU drivers and a launcher entry.
# Not apt: Zed has no official repo, and debian.griffo.io returns 401 since 2026-10.

if [ "$(uname -s)" != "Linux" ]; then
  echo "Not Linux — on macOS Zed comes from the Brewfile cask"
  exit 0
fi

if [ -x "$HOME/.local/bin/zed" ]; then
  echo "zed is already installed ($HOME/.local/bin/zed)"
  exit 0
fi

curl -fsSL https://zed.dev/install.sh | sh
echo "zed installed successfully"
