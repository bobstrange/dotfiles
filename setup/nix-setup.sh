#!/bin/bash
set -e

echo "==> Nix Setup Script for Ubuntu"

# Check if Nix is already installed
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  echo "==> Nix is already installed"
  exit 0
elif command -v nix &> /dev/null; then
  echo "==> Nix is already installed"
  exit 0
fi

echo "==> Installing Nix using Determinate Systems installer..."
# --no-confirm: without a tty the installer aborts with "Unable to run
# interactively" instead of proceeding, which kills `curl | bash` bootstraps
# and the podman-based smoke test alike.
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm

echo ""
echo "==> Nix installed successfully!"
echo ""
echo "Next steps:"
echo "  1. Restart your shell (or run: . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh)"
echo "  2. Run 'make setup-linux' to set up the development environment"
