# Common packages installed on all platforms
{ pkgs }:

with pkgs; [
  # Shell and terminal
  zsh
  tmux
  starship
  alacritty

  # Editors
  neovim
  vim

  # Git tools
  git
  tig
  lazygit

  # Search and navigation
  fzf
  bat
  ripgrep
  fd

  # Utilities
  curl
  jq
  direnv

  # Shell plugin manager
  sheldon

  # Build tools (for version managers and native extensions)
  gcc
  gnumake
  pkg-config
  openssl
]
