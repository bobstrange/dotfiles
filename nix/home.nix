{ config, pkgs, ... }:

let
  packages = import ./packages.nix { inherit pkgs; };
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

  # Generations pin store paths, so Determinate Nixd's own GC can't free them.
  services.home-manager.autoExpire = {
    enable = true;
    frequency = "weekly";
    timestamp = "-30 days";
  };

  # Add paths for user-installed binaries
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/bin"
    "$HOME/.cargo/bin"
  ];
}
