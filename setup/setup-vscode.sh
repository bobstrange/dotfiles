#!/bin/bash
set -euo pipefail

# Install Visual Studio Code from Microsoft's apt repository.
#
# Not in nix/packages.nix on purpose: nixpkgs' vscode is unfree (so it is absent
# from cache.nixos.org and every CI build re-downloads ~330MB), and extensions
# that fetch their own binaries — pylance, java, terraform, copilot — need the
# vscode-fhs wrapper to work off NixOS. The apt package has neither problem and
# tracks upstream same-day, updating through the normal `apt upgrade` path.
#
# Extensions and UI state are owned by Settings Sync, not by this repo.
# Requires: curl, sudo
# This script is idempotent, and the already-installed path needs no sudo at all,
# so re-running `make setup-linux` does not prompt for a password.

if [ "$(uname -s)" != "Linux" ]; then
  echo "Not Linux — on macOS VS Code comes from the Brewfile cask"
  exit 0
fi

if dpkg-query -W -f='${Status}' code 2>/dev/null | grep -q "^install ok installed$"; then
  echo "code $(dpkg-query -W -f='${Version}' code) is already installed"
  exit 0
fi

# Everything below changes the system. Take the password once, up front, rather
# than mid-pipeline, and say so plainly when there is no terminal to read it from.
if ! sudo -v; then
  echo "Error: this script needs sudo; run it from a terminal" >&2
  exit 1
fi

KEYRING="/usr/share/keyrings/microsoft.gpg"

# The code package's postinst writes this itself, but only after the first
# install has already found the package — which it cannot without the repo.
if [ ! -f /etc/apt/sources.list.d/vscode.list ] && [ ! -f /etc/apt/sources.list.d/vscode.sources ]; then
  echo "Registering Microsoft's apt repository..."
  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor \
    | sudo install -o root -g root -m 644 /dev/stdin "$KEYRING"
  echo "deb [arch=amd64,arm64,armhf signed-by=${KEYRING}] https://packages.microsoft.com/repos/code stable main" \
    | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
  sudo apt-get update
fi

sudo apt-get install -y code
echo "code $(dpkg-query -W -f='${Version}' code) installed successfully"
