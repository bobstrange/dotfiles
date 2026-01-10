#!/bin/bash
set -e

echo "==> Nix Setup Script for Ubuntu"

# Check if Nix is already installed
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  echo "==> Nix is already installed, sourcing daemon..."
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
elif command -v nix &> /dev/null; then
  echo "==> Nix is already installed"
else
  echo "==> Installing Nix using Determinate Systems installer..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

  echo ""
  echo "==> Nix installed. Please restart your shell and run this script again."
  exit 0
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
NIX_DIR="$DOTFILES_DIR/nix"

echo "==> Applying home-manager configuration..."
echo "    Flake directory: $NIX_DIR"

# Check if home-manager is available
if command -v home-manager &> /dev/null; then
  echo "==> home-manager found, switching configuration..."
  home-manager switch --flake "$NIX_DIR#bob@ubuntu"
else
  echo "==> Bootstrapping home-manager..."
  nix run nixpkgs#home-manager -- switch --flake "$NIX_DIR#bob@ubuntu"
fi

echo ""
echo "==> Setup complete!"
echo "    Run 'make nix-switch' to apply configuration changes"
echo "    Run 'make nix-update' to update packages"
