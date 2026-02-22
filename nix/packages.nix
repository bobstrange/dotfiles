# Nix packages for Linux/WSL
{ pkgs }:

with pkgs; [
  # Shell and terminal
  zsh
  tmux
  starship
  alacritty
  ghostty
  nixgl.nixGLIntel
  sheldon
  shellcheck

  # Editors
  neovim
  vim

  # Git
  git
  tig
  lazygit
  delta
  lefthook
  gh
  ghq

  # Search and navigation
  fzf
  bat
  eza
  ripgrep
  fd
  zoxide
  atuin

  # Utilities
  curl
  wget
  jq
  htop
  tree
  direnv

  # Build tools
  gcc
  gnumake
  pkg-config
  openssl

  # Language tools
  mise
  uv
  luarocks
  bun

  # Formatters
  dprint

  # Database
  clickhouse

  # Clipboard (X11)
  xclip
]
