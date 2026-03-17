#!/bin/bash
# Update GTK icon cache after chezmoi places icon files
if command -v gtk-update-icon-cache &>/dev/null; then
  gtk-update-icon-cache ~/.local/share/icons/hicolor/ 2>/dev/null
fi
