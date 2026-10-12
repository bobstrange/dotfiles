#!/bin/bash
set -euo pipefail

# Install Waydroid (Android in an LXC container) from its official apt
# repository, initialised with a Google Apps image so Play Store apps install.
#
# Not in nix/packages.nix on purpose: Waydroid is a root system service (LXC,
# systemd unit, AppArmor, network bridge) that the apt package wires up and nix
# off NixOS does not. Optional, so setup-linux does not depend on this.
# Google Play registration and ufw rules are printed, not applied.
#
# Requires: curl, sudo, a Wayland session
# Idempotent; the all-done path needs no sudo.

if [ "$(uname -s)" != "Linux" ]; then
  echo "Not Linux — Waydroid only runs on Linux"
  exit 0
fi

if [ "${XDG_SESSION_TYPE:-}" != "wayland" ]; then
  echo "Warning: Waydroid needs a Wayland session (current: ${XDG_SESSION_TYPE:-unknown})" >&2
fi

KEYRING="/usr/share/keyrings/waydroid.gpg"
SOURCES="/etc/apt/sources.list.d/waydroid.list"
# `waydroid init` writes this; its presence means the images are in place.
CONFIG="/var/lib/waydroid/waydroid.cfg"

have_sudo=false
need_sudo() {
  "$have_sudo" && return
  # Take the password once, up front, rather than mid-pipeline.
  if ! sudo -v; then
    echo "Error: this script needs sudo; run it from a terminal" >&2
    exit 1
  fi
  have_sudo=true
}

if [ ! -f "$SOURCES" ]; then
  # shellcheck source=/dev/null
  codename="$(. /etc/os-release && echo "$VERSION_CODENAME")"
  # The repository lags new Ubuntu releases; fail with a clear message rather
  # than leave a source that breaks every `apt-get update`.
  if ! curl -fsI "https://repo.waydro.id/dists/${codename}/Release" >/dev/null; then
    echo "Error: repo.waydro.id has no '${codename}' suite yet; see https://docs.waydro.id" >&2
    exit 1
  fi
  need_sudo
  echo "Registering the Waydroid apt repository (${codename})..."
  curl -fsSL https://repo.waydro.id/waydroid.gpg \
    | sudo install -o root -g root -m 644 /dev/stdin "$KEYRING"
  echo "deb [signed-by=${KEYRING}] https://repo.waydro.id/ ${codename} main" \
    | sudo tee "$SOURCES" >/dev/null
  sudo apt-get update
fi

if ! dpkg-query -W -f='${Status}' waydroid 2>/dev/null | grep -q "^install ok installed$"; then
  need_sudo
  sudo apt-get install -y waydroid
fi

initialised_now=false
if [ ! -f "$CONFIG" ]; then
  need_sudo
  echo "Downloading the Android images (GAPPS, about 1GB)..."
  sudo waydroid init -s GAPPS
  initialised_now=true
fi

if ! systemctl is-enabled --quiet waydroid-container || ! systemctl is-active --quiet waydroid-container; then
  need_sudo
  sudo systemctl enable --now waydroid-container
fi

echo "waydroid $(dpkg-query -W -f='${Version}' waydroid) ready; start it with: waydroid show-full-ui"

# /etc/ufw/ufw.conf is world-readable, so this check needs no sudo.
if grep -q '^ENABLED=yes' /etc/ufw/ufw.conf 2>/dev/null; then
  cat <<'EOF'

ufw is enabled; if Android has no network, allow DNS/DHCP and forwarding:
  sudo ufw allow 53 && sudo ufw allow 67 && sudo ufw default allow FORWARD
EOF
fi

if "$initialised_now"; then
  cat <<'EOF'

Next: register the device with Google Play (the GAPPS image is uncertified):
  1. waydroid show-full-ui, wait for Android to boot, then: sudo waydroid shell
  2. In that shell, print the device's android_id:
       ANDROID_RUNTIME_ROOT=/apex/com.android.runtime ANDROID_DATA=/data \
       ANDROID_TZDATA_ROOT=/apex/com.android.tzdata ANDROID_I18N_ROOT=/apex/com.android.i18n \
       sqlite3 /data/data/com.google.android.gsf/databases/gservices.db \
       "select * from main where name = \"android_id\";"
  3. Register the number at https://www.google.com/android/uncertified
  4. Once it takes effect (minutes to hours): waydroid session stop, then waydroid show-full-ui
     If Play Store still refuses, clear its storage in Android Settings → Apps
EOF
fi
