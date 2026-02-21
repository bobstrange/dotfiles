# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About This Repository

This is a personal dotfiles repository managed with:
- **[chezmoi](https://www.chezmoi.io/)**: Dotfile management (config files)
- **[Homebrew](https://brew.sh/) + Brewfile**: Package management (macOS)
- **[Nix Flakes](https://nixos.wiki/wiki/Flakes) + [home-manager](https://github.com/nix-community/home-manager)**: Package management (Ubuntu/WSL)

Supports macOS, Ubuntu, and WSL environments.

## Key Commands

### Nix Package Management (Ubuntu/WSL)

```bash
# Initial setup (run in order)
make nix-install      # 1. Install Nix (requires shell restart)
make nix-bootstrap    # 2. Install home-manager and packages

# Daily use
make nix-apply        # Apply changes after editing nix/*.nix
make nix-update       # Update all packages to latest versions

# Search packages
nix search nixpkgs <package-name>
```

### Homebrew (macOS)

```bash
make macos-setup    # Initial setup (brew bundle + defaults)
make macos-install  # Install/update packages
make macos-defaults # Apply macOS system defaults
make symlinks       # Symlink secret files from Dropbox (~/.ssh, ~/.aws, tokens)
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

| Concern | Tool |
|---------|------|
| Dotfiles (.zshrc, .vimrc, etc.) | chezmoi |
| Packages - macOS | Homebrew + Brewfile |
| Packages - Ubuntu/WSL | Nix + home-manager |
| macOS system configuration | `setup/macos/defaults.sh` |
| Secret files (~/.ssh, ~/.aws) | `setup/symlinks.sh` (Dropbox) |

### Adding Packages

- **macOS**: Edit `Brewfile`, run `make macos-install`
- **Ubuntu/WSL**: Edit `nix/packages/common.nix` (or `ubuntu.nix`), run `make nix-apply`

## Development Notes

- Nix provides reproducible builds via `flake.lock`
- Rollback: `home-manager rollback`
- Configuration is modular - individual components can be modified without affecting others
- Shell functions and aliases are organized by platform in `dot_zsh/configs/`
- See `docs/2026-01-12_nix-migration.md` for detailed migration documentation
