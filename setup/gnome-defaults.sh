#!/bin/bash
set -euo pipefail

# GNOME system defaults (equivalent of macOS defaults.sh)
# Requires: gsettings, GNOME Shell
# This script is idempotent — safe to run multiple times.

echo "Applying GNOME defaults..."

# Disable Alt+Space window menu (conflicts with Ulauncher keybind via xremap)
gsettings set org.gnome.desktop.wm.keybindings activate-window-menu "[]"

# Astra Monitor: show CPU % and memory usage in top bar
dconf write /org/gnome/shell/extensions/astra-monitor/processor-header-percentage true
dconf write /org/gnome/shell/extensions/astra-monitor/memory-header-value true

echo "Done."
