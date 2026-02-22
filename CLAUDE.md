# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About This Repository

This is a personal dotfiles repository managed with:

- **[chezmoi](https://www.chezmoi.io/)**: Dotfile management (config files)
- **[Homebrew](https://brew.sh/) + Brewfile**: Package management (macOS)
- **[Nix Flakes][nix] + [home-manager][hm]**: Package management (Ubuntu/WSL)

[nix]: https://nixos.wiki/wiki/Flakes
[hm]: https://github.com/nix-community/home-manager

Supports macOS, Ubuntu, and WSL environments.

## Key Commands

Run `make help` to see all available targets.

## Architecture

### File Structure

```text
~/.local/share/chezmoi/
├── nix/                    # Nix package management (Ubuntu/WSL)
│   ├── flake.nix           # Flake definition (inputs, outputs)
│   ├── flake.lock          # Version lockfile (auto-generated)
│   ├── home.nix            # home-manager config
│   └── packages/
│       └── packages.nix    # All packages (Linux/WSL)
├── setup/
│   ├── bootstrap.sh        # One-liner bootstrap for fresh machines
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

### Responsibility Matrix

| Concern                         | Tool                                                  |
| ------------------------------- | ----------------------------------------------------- |
| Dotfiles (.zshrc, .vimrc, etc.) | chezmoi                                               |
| Packages - macOS                | Homebrew + Brewfile                                   |
| Packages - Ubuntu/WSL           | Nix + home-manager (packages only; `home.file = { }`) |
| Shell configuration             | `dot_zsh/configs/` (modular by platform)              |
| macOS system configuration      | `setup/macos/defaults.sh`                             |
| Secret files (~/.ssh, ~/.aws)   | `setup/symlinks.sh` (Dropbox)                         |

### Adding Packages

- **macOS**: Edit `Brewfile`, run `make macos-apply`
- **Ubuntu/WSL**: Edit `nix/packages/packages.nix`, run `make nix-apply` (or use `nix-add` shell function)

## Development Notes

- `dot_*.tmpl` files are chezmoi templates (Go text/template) — edit these, not the `$HOME` targets
- Nix provides reproducible builds via `flake.lock`
- Rollback: `home-manager rollback`
- Configuration is modular - individual components can be modified without affecting others
- See `docs/` for setup and migration notes
