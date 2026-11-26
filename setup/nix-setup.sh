#!/bin/bash
set -e

echo "==> Nix Setup Script for Ubuntu"

if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ] || command -v nix &> /dev/null; then
  echo "==> Nix is already installed"
  fresh_install=false
else
  echo "==> Installing Nix using Determinate Systems installer..."
  # --no-confirm: without a tty the installer aborts with "Unable to run
  # interactively" instead of proceeding, which kills `curl | bash` bootstraps
  # and the podman-based smoke test alike.
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
  fresh_install=true
fi

# Not nix.conf (Determinate regenerates it) nor ~/.config/nix/nix.conf (the daemon ignores store options there).
custom_conf=/etc/nix/nix.custom.conf
if ! grep -qx 'auto-optimise-store = true' "$custom_conf" 2>/dev/null; then
  echo "==> Enabling auto-optimise-store in $custom_conf"
  echo 'auto-optimise-store = true' | sudo tee -a "$custom_conf" > /dev/null
  if command -v systemctl &> /dev/null && systemctl is-active --quiet nix-daemon; then
    sudo systemctl restart nix-daemon
  fi
fi

if [ "$fresh_install" = true ]; then
  echo ""
  echo "==> Nix installed successfully!"
  echo ""
  echo "Next steps:"
  echo "  1. Restart your shell (or run: . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh)"
  echo "  2. Run 'make setup-linux' to set up the development environment"
fi
