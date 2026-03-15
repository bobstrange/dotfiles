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
2. Install packages (Homebrew on macOS, Nix on Linux) via `make setup-macos` / `make setup-linux`
3. Apply dotfiles (encrypted files are skipped if age key is not yet restored)

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

1. (Optional) Link Dropbox secrets (`~/.aws`, tokens):

```bash
make symlinks   # Requires ~/Dropbox/config
```

## Help

```bash
make help
```
