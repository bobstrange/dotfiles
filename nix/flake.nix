{
  description = "bob's dotfiles - package management with Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixgl }:
    let
      linuxSystem = "x86_64-linux";
      pkgs = import nixpkgs {
        system = linuxSystem;
        overlays = [
          nixgl.overlay
          # cli-helpers 2.10.0 has failing tests due to Pygments 2.20.0 changing the
          # 256-color mapping for #eeeeee (bg:#eee) from color 7 to color 255.
          # The fix is in cli-helpers v2.10.1+. Remove this override once nixpkgs
          # unstable updates python3Packages.cli-helpers to >= 2.10.1.
          (final: prev: {
            python3 = prev.python3.override {
              packageOverrides = pyFinal: pyPrev: {
                cli-helpers = pyPrev.cli-helpers.overrideAttrs (_: { doCheck = false; });
              };
            };
          })
        ];
      };
    in
    {
      homeConfigurations = {
        # Ubuntu configuration
        "bob@ubuntu" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            {
              home.username = "bob";
              home.homeDirectory = "/home/bob";
            }
          ];
        };

        # WSL configuration (same as ubuntu for now)
        "bob@wsl" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            {
              home.username = "bob";
              home.homeDirectory = "/home/bob";
            }
          ];
        };
      };

      # Development shell for working on this flake
      devShells.${linuxSystem}.default = pkgs.mkShell {
        packages = [ pkgs.home-manager ];
      };
    };
}
