# dotfiles

## Requirements

- Dropbox has been installed.
- Dropbox folder should be `~/Dropbox/`.

## Tools

- **[chezmoi](https://www.chezmoi.io/)**: Dotfile management
- **[Homebrew](https://brew.sh/) + Brewfile**: Package management (macOS)
- **[Nix Flakes][nix] + [home-manager][hm]**: Package management (Ubuntu/WSL)

[nix]: https://nixos.wiki/wiki/Flakes
[hm]: https://github.com/nix-community/home-manager

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

### Nix vs mise

| Category                | Manager                             | Examples                           |
| ----------------------- | ----------------------------------- | ---------------------------------- |
| CLI tools and utilities | Nix (`nix/packages.nix`)            | bun, fzf, ripgrep, jq, gh          |
| Language runtimes       | mise (`~/.config/mise/config.toml`) | node, ruby, python, erlang, elixir |

- **Nix**: Reproducible, declarative. Good for tools where exact version doesn't matter much.
- **mise**: Tracks `latest`/`lts`, supports per-project `.mise.toml` for version switching.
  nixpkgs can lag behind on language runtimes (e.g. Ruby 3.3 when 4.0 is out).

## Help

```bash
make help
```
