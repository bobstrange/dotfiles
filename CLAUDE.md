# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About This Repository

This is a personal dotfiles repository managed with:
- **[chezmoi](https://www.chezmoi.io/)**: Dotfile management (config files)
- **[Nix Flakes](https://nixos.wiki/wiki/Flakes) + [home-manager](https://github.com/nix-community/home-manager)**: Package management (Ubuntu/WSL)
- **[Ansible](https://www.ansible.com/)**: Legacy package management (macOS)

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

### Ansible (Legacy/macOS)

- Run Ansible playbook: `cd setup/ansible && ansible-playbook -i inventory/hosts.yml playbooks/setup.yml --limit [osx|ubuntu|wsl] --ask-become -v`
- Quick Ubuntu setup: `make run-ubuntu`

### Chezmoi (Dotfiles)

- Apply changes: `chezmoi apply`
- Check differences: `chezmoi diff`
- Edit files: `chezmoi edit <file>`
- Add new files: `chezmoi add <file>`

## Architecture

### File Structure

```
~/.local/share/chezmoi/
├── nix/                    # Nix package management
│   ├── flake.nix           # Flake definition (inputs, outputs)
│   ├── flake.lock          # Version lockfile (auto-generated)
│   ├── home.nix            # home-manager config
│   └── packages/
│       ├── common.nix      # Cross-platform packages
│       └── ubuntu.nix      # Ubuntu-specific packages
├── setup/
│   └── nix-setup.sh        # Nix installation script
├── dot_*                   # Chezmoi dotfiles (become .* in home)
└── Makefile                # Build targets
```

### Key Components

- **Nix Flakes** (`nix/`) handle declarative package management with lockfile
- **home-manager** manages packages only (`home.file = { }` leaves dotfiles to chezmoi)
- **chezmoi** manages all dotfiles (shell configs, editor configs, etc.)
- **Shell configuration** split across `dot_zsh/` with modular configs and functions
- **Ansible roles** in `setup/ansible/roles/` (legacy, for macOS)

### Package Management Design

| Concern | Tool |
|---------|------|
| Dotfiles (.zshrc, .vimrc, etc.) | chezmoi |
| Packages (zsh, neovim, fzf, etc.) | Nix + home-manager |
| System configuration | Manual / Ansible |

### Adding Packages

1. Edit `nix/packages/common.nix` (or `ubuntu.nix` for platform-specific)
2. Run `make nix-apply`

## Development Notes

- Nix provides reproducible builds via `flake.lock`
- Rollback: `home-manager rollback`
- Configuration is modular - individual components can be modified without affecting others
- Shell functions and aliases are organized by platform in `dot_zsh/configs/`
- See `docs/2026-01-12_nix-migration.md` for detailed migration documentation
