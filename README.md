# dotfiles

## Requirements

- age key restored at `~/.config/chezmoi/key.txt` (from 1Password) for encrypted files
- (Optional) Dropbox at `~/Dropbox/` for secret symlinks (`~/.aws`, tokens)

## Tools

- **[chezmoi](https://www.chezmoi.io/)**: Dotfile management
- **[Homebrew](https://brew.sh/) + Brewfile**: Package management (macOS)
- **[Nix Flakes][nix] + [home-manager][hm]**: Package management (Ubuntu/WSL)
- **[mise](https://mise.jdx.dev/)**: Language runtime version management

[nix]: https://nixos.wiki/wiki/Flakes
[hm]: https://github.com/nix-community/home-manager

Supports macOS, Ubuntu, and WSL environments.

## Setup

Run this on a fresh machine (macOS or Linux/WSL):

```bash
curl -fsLS https://raw.githubusercontent.com/bobstrange/dotfiles/main/setup/bootstrap.sh | bash
```

This will:

1. Install chezmoi and clone this repo
1. Install packages (Homebrew on macOS, Nix on Linux) via `make setup-macos` / `make setup-linux`
1. Apply dotfiles (encrypted files are skipped if age key is not yet restored)

### Daily Operations

#### macOS

```bash
make macos-apply      # Apply Brewfile changes
make macos-defaults   # Apply macOS system defaults
```

> **Note:** `make setup-macos` does not include `lefthook-setup`. Run `make lefthook-setup` separately
> after initial setup to install git hooks.

#### Ubuntu/WSL

```bash
make nix-apply        # After editing nix/*.nix files
make nix-update       # Update all packages to latest
make gnome-defaults   # Apply GNOME system preferences
nix search nixpkgs <package-name>  # Search for packages
home-manager rollback              # Rollback to previous generation
```

### Git Hooks

[lefthook](https://github.com/evilmartians/lefthook) runs pre-commit checks automatically after
`make lefthook-setup` (or `make setup-linux`):

| Hook                | Files                                         | Tool                |
| ------------------- | --------------------------------------------- | ------------------- |
| trailing-whitespace | all staged files                              | `git diff --check`  |
| dprint-check        | `*.md`, `*.json`, `*.yaml`, `*.yml`, `*.toml` | `dprint`            |
| markdownlint        | `*.md`                                        | `markdownlint-cli2` |

Markdown line length is enforced at 120 characters (see `.markdownlint-cli2.yaml`).

### Adding Packages

- **macOS**: Edit `Brewfile`, run `make macos-apply`
- **Ubuntu/WSL**: Edit `nix/packages.nix`, run `make nix-apply`

### Utility Scripts

Scripts in `bin/` are installed to `~/bin/`, and `dot_local/bin/` to `~/.local/bin/`:

| Script                       | Description                              |
| ---------------------------- | ---------------------------------------- |
| `claude-search-sessions.py`  | Search Claude Code session logs          |
| `ghostty-wrapper`            | Ghostty terminal launcher (Linux)        |
| `neovide-launcher`           | Neovide desktop launcher (Linux)         |
| `update-git-delta-themes.sh` | Update git-delta color theme definitions |

Desktop entries and icons for Linux are managed in `dot_local/share/`.

### Nix vs mise

| Category                | Manager                             | Examples                           |
| ----------------------- | ----------------------------------- | ---------------------------------- |
| CLI tools and utilities | Nix (`nix/packages.nix`)            | bun, fzf, ripgrep, jq, gh          |
| Language runtimes       | mise (`~/.config/mise/config.toml`) | node, ruby, python, erlang, elixir |

- **Nix**: Reproducible, declarative. Good for tools where exact version doesn't matter much.
- **mise**: Tracks `latest`/`lts`, supports per-project `.mise.toml` for version switching.
  nixpkgs can lag behind on language runtimes (e.g. Ruby 3.3 when 4.0 is out).

## Post-Bootstrap Steps

1. Restore the age key and apply encrypted files:

```bash
mkdir -p ~/.config/chezmoi
vim ~/.config/chezmoi/key.txt   # Paste from 1Password
chmod 600 ~/.config/chezmoi/key.txt
chezmoi apply                   # Now includes encrypted files (e.g. SSH work config)
```

2. (Optional) Link Dropbox secrets (`~/.aws`, tokens):

```bash
make symlinks   # Requires ~/Dropbox/config
```

## Make Targets

```bash
make help
```

| Target                   | Description                           |
| ------------------------ | ------------------------------------- |
| `setup-nix`              | Install Nix package manager           |
| `setup-linux`            | Set up Linux development environment  |
| `setup-macos`            | Set up macOS development environment  |
| `nix-apply`              | Apply Nix package config changes      |
| `nix-update`             | Update Nix packages to latest         |
| `macos-apply`            | Apply Homebrew package config changes |
| `lefthook-setup`         | Set up git hooks                      |
| `xremap-setup`           | Set up key remapper (Linux/GNOME)     |
| `gnome-extensions-setup` | Install GNOME Shell extensions        |
| `ulauncher-setup`        | Install Ulauncher v6 launcher         |
| `gnome-defaults`         | Apply GNOME system preferences        |
| `mise-install`           | Install language runtimes             |
| `symlinks`               | Link secret files from Dropbox        |
| `macos-defaults`         | Apply macOS system preferences        |
