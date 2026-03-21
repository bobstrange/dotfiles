#!/bin/bash
set -euo pipefail

# GNOME system defaults (equivalent of macOS defaults.sh)
# Requires: gsettings, GNOME Shell
# This script is idempotent — safe to run multiple times.

echo "Applying GNOME defaults..."

# Disable Alt+Space window menu (conflicts with Ulauncher keybind via xremap)
gsettings set org.gnome.desktop.wm.keybindings activate-window-menu "[]"

echo "Done."
