{ config, pkgs, ... }:

let
  commonPackages = import ./packages/common.nix { inherit pkgs; };
  ubuntuPackages = import ./packages/ubuntu.nix { inherit pkgs; };
in
{
  # home-manager version compatibility
  home.stateVersion = "24.05";

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # CRITICAL: Do not let home-manager manage any dotfiles
  # chezmoi handles all dotfile management
  home.file = { };

  # Package installation only
  home.packages = commonPackages ++ ubuntuPackages;

  # Add paths for user-installed binaries
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/bin"
    "$HOME/.cargo/bin"
  ];
}
