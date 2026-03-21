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

Run `make help` to see all available targets. Summary:

- **Initial setup**: `make setup-nix`, `make setup-linux`, `make setup-macos`
- **Apply changes**: `make nix-apply`, `make macos-apply`
- **Update packages**: `make nix-update`
- **Tools**: `make lefthook-setup`, `make xremap-setup`, `make gnome-extensions-setup`,
  `make mise-install`, `make symlinks`, `make macos-defaults`

## Architecture

### File Structure

```text
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl      # chezmoi config template (age encryption)
├── .chezmoiignore          # Files excluded from chezmoi apply
├── bin/                    # Executable scripts (added to ~/bin)
├── dot_config/             # ~/.config/* (ghostty, nvim, starship, etc.)
├── dot_local/              # ~/.local/* (desktop files, scripts)
├── dot_zsh/                # Shell config (modular by platform)
├── nix/                    # Nix package management (Ubuntu/WSL)
│   ├── flake.nix           # Flake definition (inputs, outputs)
│   ├── flake.lock          # Version lockfile (auto-generated)
│   ├── home.nix            # home-manager config (packages + sessionPath)
│   └── packages.nix        # All packages (Linux/WSL)
├── private_dot_ssh/        # ~/.ssh (managed by chezmoi, includes encrypted files)
├── setup/
│   ├── bootstrap.sh        # One-liner bootstrap for fresh machines
│   ├── nix-setup.sh        # Nix installation script
│   ├── gnome-extensions.sh # Install GNOME Shell extensions (Linux)
│   ├── lefthook-gen.sh     # Generate lefthook.yml with extends
│   ├── setup-xremap.sh     # xremap key remapper setup (Linux/GNOME)
│   ├── setup.ps1           # Windows/PowerShell setup
│   ├── symlinks.sh         # Symlink secret files from Dropbox (~/.aws, tokens)
│   ├── README.Ubuntu.md    # Ubuntu-specific setup notes
│   └── macos/
│       └── defaults.sh     # macOS system defaults
├── Brewfile                # macOS package management
├── dot_aerospace.toml      # Aerospace window manager (macOS)
├── dot_*                   # Other chezmoi dotfiles (become .* in home)
└── Makefile                # Build targets
```

### Responsibility Matrix

| Concern                         | Tool                                               |
| ------------------------------- | -------------------------------------------------- |
| Dotfiles (.zshrc, .vimrc, etc.) | chezmoi                                            |
| SSH (~/.ssh)                    | chezmoi (`private_dot_ssh/`, encrypted with age)   |
| Secrets (~/.aws, tokens)        | `setup/symlinks.sh` (Dropbox `~/Dropbox/config`)   |
| Packages - macOS                | Homebrew + Brewfile                                |
| Packages - Ubuntu/WSL           | Nix + home-manager (packages + `home.sessionPath`) |
| Language runtimes               | mise (`~/.config/mise/config.toml`)                |
| Shell configuration             | `dot_zsh/configs/` (modular by platform)           |
| macOS window manager            | Aerospace (`dot_aerospace.toml`)                   |
| GNOME extensions                | `setup/gnome-extensions.sh`                        |
| macOS system configuration      | `setup/macos/defaults.sh`                          |

### Adding Packages

- **macOS**: Edit `Brewfile`, run `make macos-apply`
- **Ubuntu/WSL**: Edit `nix/packages.nix`, run `make nix-apply` (or use `nix-add` shell function)

### Nix vs mise: Package Management Guidelines

- **Nix** (`nix/packages.nix`): CLI tools, utilities, and packages where the latest version is not critical
  (e.g. bun, fzf, ripgrep, jq, gh, neovim)
- **mise** (`~/.config/mise/config.toml`): Language runtimes that need version switching per project or
  tracking `latest`/`lts` (e.g. node, ruby, python, erlang, elixir)

Rationale: nixpkgs can lag behind on language runtimes (e.g. Ruby 3.3 vs 4.0), while mise provides
flexible version management with `latest`, `lts`, and per-project `.mise.toml` overrides.

## Development Notes

- Any `.tmpl` file (root or nested, e.g. `dot_config/ghostty/config.tmpl`) is a chezmoi template
  (Go text/template) — edit these, not the `$HOME` targets
- Nix provides reproducible builds via `flake.lock`
- Rollback: `home-manager rollback`
- `make nix-apply` auto-commits `nix/flake.lock` if it changes — be aware of this side effect
- Configuration is modular - individual components can be modified without affecting others
