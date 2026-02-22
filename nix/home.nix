{ config, pkgs, ... }:

let
  packages = import ./packages/packages.nix { inherit pkgs; };
in
{
  # home-manager version compatibility
  home.stateVersion = "24.05";

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # Disable news notifications
  news.display = "silent";

  # CRITICAL: Do not let home-manager manage any dotfiles
  # chezmoi handles all dotfile management
  home.file = { };

  # Package installation only
  home.packages = packages;

  # Add paths for user-installed binaries
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/bin"
    "$HOME/.cargo/bin"
  ];
}
