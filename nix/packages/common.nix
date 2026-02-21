# Common packages installed on all platforms
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

  # Search and navigation
  fzf
  bat
  ripgrep
  fd

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

  # Formatters
  dprint

  # Database
  clickhouse
]
