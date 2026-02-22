# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About This Repository

This is a personal dotfiles repository managed with:

- **[chezmoi](https://www.chezmoi.io/)**: Dotfile management (config files)
- **[Homebrew](https://brew.sh/) + Brewfile**: Package management (macOS)
- **[Nix Flakes](https://nixos.wiki/wiki/Flakes) + [home-manager](https://github.com/nix-community/home-manager)**: Package management (Ubuntu/WSL)

Supports macOS, Ubuntu, and WSL environments.

## Key Commands

### Initial Setup (run once)

```bash
make setup-nix        # Install Nix package manager (requires shell restart)
make setup-linux      # Set up Linux development environment
make setup-macos      # Set up macOS development environment

# Search packages
nix search nixpkgs <package-name>
```

### Apply Config Changes

```bash
make nix-apply        # Apply Nix package config changes
make macos-apply      # Apply Homebrew package config changes
```

### Update Packages

```bash
make nix-update       # Update Nix packages to latest
```

### Tools

```bash
make lefthook-setup   # Set up git hooks
make xremap-setup     # Set up key remapper (Linux/GNOME)
make mise-install     # Install language runtimes
make symlinks         # Link secret files from Dropbox
make macos-defaults   # Apply macOS system preferences
```

### Chezmoi (Dotfiles)

- Apply changes: `chezmoi apply`
- Check differences: `chezmoi diff`
- Edit files: `chezmoi edit <file>`
- Add new files: `chezmoi add <file>`

## Architecture

### File Structure

```
~/.local/share/chezmoi/
├── nix/                    # Nix package management (Ubuntu/WSL)
│   ├── flake.nix           # Flake definition (inputs, outputs)
│   ├── flake.lock          # Version lockfile (auto-generated)
│   ├── home.nix            # home-manager config
│   └── packages/
│       ├── common.nix      # Cross-platform packages
│       └── ubuntu.nix      # Ubuntu-specific packages
├── setup/
│   ├── nix-setup.sh        # Nix installation script
│   ├── lefthook-gen.sh     # Generate lefthook.yml with extends
│   ├── setup-xremap.sh     # xremap key remapper setup (Linux/GNOME)
│   ├── symlinks.sh         # Symlink secret files from Dropbox
│   └── macos/
│       └── defaults.sh     # macOS system defaults
├── Brewfile                # macOS package management
├── dot_*                   # Chezmoi dotfiles (become .* in home)
└── Makefile                # Build targets
```

### Key Components

- **Homebrew + Brewfile** manage macOS packages declaratively
- **Nix Flakes** (`nix/`) handle declarative package management with lockfile (Ubuntu/WSL)
- **home-manager** manages packages only (`home.file = { }` leaves dotfiles to chezmoi)
- **chezmoi** manages all dotfiles (shell configs, editor configs, etc.)
- **Shell configuration** split across `dot_zsh/` with modular configs and functions

### Package Management Design

| Concern                         | Tool                          |
| ------------------------------- | ----------------------------- |
| Dotfiles (.zshrc, .vimrc, etc.) | chezmoi                       |
| Packages - macOS                | Homebrew + Brewfile           |
| Packages - Ubuntu/WSL           | Nix + home-manager            |
| macOS system configuration      | `setup/macos/defaults.sh`     |
| Secret files (~/.ssh, ~/.aws)   | `setup/symlinks.sh` (Dropbox) |

### Adding Packages

- **macOS**: Edit `Brewfile`, run `make macos-apply`
- **Ubuntu/WSL**: Edit `nix/packages/common.nix` (or `ubuntu.nix`), run `make nix-apply`

## Development Notes

- Nix provides reproducible builds via `flake.lock`
- Rollback: `home-manager rollback`
- Configuration is modular - individual components can be modified without affecting others
- Shell functions and aliases are organized by platform in `dot_zsh/configs/`
- See `docs/2026-01-12_nix-migration.md` for detailed migration documentation
