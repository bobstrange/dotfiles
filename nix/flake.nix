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
        overlays = [ nixgl.overlay ];
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
