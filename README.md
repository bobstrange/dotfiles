# dotfiles

## Requirements

- Dropbox has been installed.
- Dropbox folder should be `~/Dropbox/`.

## Tools

- **[chezmoi](https://www.chezmoi.io/)**: Dotfile management
- **[Homebrew](https://brew.sh/) + Brewfile**: Package management (macOS)
- **[Nix Flakes](https://nixos.wiki/wiki/Flakes) + [home-manager](https://github.com/nix-community/home-manager)**: Package management (Ubuntu/WSL)

## Setup

Run this on a fresh machine (macOS or Linux/WSL):

```bash
curl -fsLS https://raw.githubusercontent.com/bobstrange/dotfiles/main/setup/bootstrap.sh | bash
```

This will:

1. Install chezmoi and clone this repo
2. Install packages (Homebrew on macOS, Nix on Linux)
3. Apply dotfiles

### Daily Operations

#### macOS

```bash
make macos-apply      # Apply Brewfile changes
make macos-defaults   # Apply macOS system defaults
```

#### Ubuntu/WSL

```bash
make nix-apply        # After editing nix/*.nix files
make nix-update       # Update all packages to latest
nix search nixpkgs <package-name>  # Search for packages
home-manager rollback              # Rollback to previous generation
```

## Help

```bash
make help
```
