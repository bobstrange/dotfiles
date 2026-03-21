#!/bin/bash
set -euo pipefail

# Install and enable GNOME Shell extensions via gnome-extensions-cli (gext).
# Requires: uv (for uvx), GNOME Shell
# This script is idempotent — safe to run multiple times.

gext() {
  uvx --from gnome-extensions-cli gext "$@"
}

extensions=(
  "xremap@k0kubun.com"
  "monitor@astraext.github.io"
)

for ext in "${extensions[@]}"; do
  if gnome-extensions list 2>/dev/null | grep -q "$ext"; then
    echo "$ext: already installed"
  else
    echo "$ext: installing..."
    gext install "$ext"
  fi

  if ! gnome-extensions list --enabled 2>/dev/null | grep -q "$ext"; then
    echo "$ext: enabling..."
    gext enable "$ext"
  fi
done
