#!/bin/bash
set -euo pipefail

# Install Ulauncher v6 (beta) from GitHub releases.
# Uses .deb package since v6 is not yet available in nixpkgs.
# Requires: curl, sudo
# This script is idempotent — safe to run multiple times.

REPO="Ulauncher/Ulauncher"
INSTALL_DIR="/tmp/ulauncher-install"

# Get the latest v6 pre-release tag
latest_tag=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases" \
  | jq -r '[.[] | select(.tag_name | startswith("v6"))][0].tag_name')

if [ -z "$latest_tag" ] || [ "$latest_tag" = "null" ]; then
  echo "Error: could not find a v6 release"
  exit 1
fi

# Check currently installed version
current_version=$(dpkg-query -W -f='${Version}' ulauncher 2>/dev/null || echo "")
release_version="${latest_tag#v}"

if [ "$current_version" = "$release_version" ]; then
  echo "ulauncher ${current_version} is already installed"
  exit 0
fi

echo "Installing ulauncher ${release_version} (current: ${current_version:-none})..."

# Download and install .deb
mkdir -p "$INSTALL_DIR"
# deb filename uses dots instead of hyphens (e.g. 6.0.0.beta29 not 6.0.0-beta29)
deb_version="${release_version//-/.}"
deb_name="ulauncher_${deb_version}_all.deb"
deb_url="https://github.com/${REPO}/releases/download/${latest_tag}/${deb_name}"

curl -fsSL -o "${INSTALL_DIR}/${deb_name}" "$deb_url"
sudo apt install -y "${INSTALL_DIR}/${deb_name}"
rm -rf "$INSTALL_DIR"

echo "ulauncher ${release_version} installed successfully"

# Enable systemd service for auto-start
if ! systemctl --user is-enabled ulauncher &>/dev/null; then
  echo "Enabling ulauncher systemd service..."
  systemctl --user enable --now ulauncher
fi
