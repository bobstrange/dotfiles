#!/bin/bash
set -euo pipefail

# Install rootless podman from Ubuntu's own repository.
#
# Not in nix/packages.nix on purpose: nixpkgs' podman ships without an AppArmor
# profile, so on Ubuntu rootless user namespaces are refused, and rootless mode
# also needs the setuid newuidmap/newgidmap that only apt's `uidmap` provides.
# Same exception as VS Code (setup-vscode.sh). Only `make bootstrap-test`
# (setup/test-bootstrap.sh) needs it, so setup-linux does not depend on this.
#
# Requires: sudo
# Idempotent; the already-installed path needs no sudo.

if [ "$(uname -s)" != "Linux" ]; then
  echo "Not Linux — the bootstrap smoke test only targets Ubuntu"
  exit 0
fi

installed() {
  dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "^install ok installed$"
}

# slirp4netns is the rootless network backend on podman 4 (24.04); podman 5
# (26.04) defaults to pasta, which lives in `passt`. Install both so the same
# script works on either side of the upgrade.
PACKAGES=(podman uidmap slirp4netns passt)
missing=()
for pkg in "${PACKAGES[@]}"; do
  installed "$pkg" || missing+=("$pkg")
done

if [ "${#missing[@]}" -gt 0 ]; then
  if ! sudo -v; then
    echo "Error: this script needs sudo; run it from a terminal" >&2
    exit 1
  fi
  sudo apt-get install -y "${missing[@]}"
fi

# Rootless podman maps container uids onto a subordinate range; without an
# entry here every `podman run` fails with "no subuid ranges found".
for f in /etc/subuid /etc/subgid; do
  if ! grep -q "^$(id -un):" "$f"; then
    echo "Error: no entry for $(id -un) in $f; add one with: sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $(id -un)" >&2
    exit 1
  fi
done

if [ "$(podman info --format '{{.Host.Security.Rootless}}')" != "true" ]; then
  echo "Error: podman is installed but not running rootless" >&2
  exit 1
fi

echo "podman $(podman --version | awk '{print $3}') ready (rootless)"
