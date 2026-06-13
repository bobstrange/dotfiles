# dotfiles

## Tools

- **[chezmoi](https://www.chezmoi.io/)**: Dotfile management
- **[Homebrew](https://brew.sh/) + Brewfile**: Package management (macOS)
- **[Nix Flakes][nix] + [home-manager][hm]**: Package management (Ubuntu/WSL)
- **[mise](https://mise.jdx.dev/)**: Language runtime version management

[nix]: https://nixos.wiki/wiki/Flakes
[hm]: https://github.com/nix-community/home-manager

Supports macOS, Ubuntu, and WSL environments.

## Setup

Run this on a fresh machine:

```bash
curl -fsLS https://raw.githubusercontent.com/bobstrange/dotfiles/main/setup/bootstrap.sh | bash
```

This will:

1. Install chezmoi and clone this repo
2. Install packages via the appropriate make target:
   - macOS: `make setup-macos` (Homebrew)
   - Ubuntu (GNOME desktop): `make setup-linux` (Nix + GNOME extensions + xremap)
   - WSL: `make setup-wsl` (Nix only — GNOME and xremap are skipped automatically)
3. Apply dotfiles (encrypted files are skipped if age key is not yet restored)

> **WSL:** The bootstrap script detects WSL automatically via `/proc/version` and runs
> `make setup-wsl` instead of `make setup-linux`, skipping GNOME extensions, Ulauncher,
> and xremap which are not applicable in WSL.

### Post-Bootstrap Steps

1. Restore the age key and apply encrypted files:

```bash
mkdir -p ~/.config/chezmoi
vim ~/.config/chezmoi/key.txt   # Paste from 1Password
chmod 600 ~/.config/chezmoi/key.txt
chezmoi apply                   # Now includes encrypted files (e.g. SSH work config)
```

2. Configure machine type (work/personal):

```bash
make local-config   # interactive prompt
# or non-interactively:
./setup/setup-local-config.sh --work
./setup/setup-local-config.sh --personal
```

| Variable    | Effect                                                                           |
| ----------- | -------------------------------------------------------------------------------- |
| `work=true` | Skips `dot_claude/` — `~/.claude/` is managed by agent-configs symlinks instead |

3. (Optional) Link Dropbox secrets (`~/.aws`, tokens):

```bash
make symlinks   # Requires ~/Dropbox/config
```

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
make nix-apply        # After editing nix/*.nix files (auto-commits nix/flake.lock if changed)
make nix-update       # Update all packages to latest (auto-commits nix/flake.lock if changed)
nix search nixpkgs <package-name>  # Search for packages
home-manager rollback              # Rollback to previous generation
```

On Ubuntu (GNOME desktop) only:

```bash
make gnome-defaults   # Apply GNOME system preferences
```

### Adding Packages

- **macOS**: Edit `Brewfile`, run `make macos-apply`
- **Ubuntu/WSL**: Edit `nix/packages.nix`, run `make nix-apply`

### Git Hooks

[lefthook](https://github.com/evilmartians/lefthook) runs pre-commit checks automatically after
`make lefthook-setup` (included in `make setup-linux` and `make setup-wsl`):

| Hook                | Files                                         | Tool                |
| ------------------- | --------------------------------------------- | ------------------- |
| trailing-whitespace | all staged files                              | `git diff --check`  |
| dprint-check        | `*.md`, `*.json`, `*.yaml`, `*.yml`, `*.toml` | `dprint`            |
| markdownlint        | `*.md`                                        | `markdownlint-cli2` |

Markdown line length is enforced at 120 characters (see `.markdownlint-cli2.yaml`).

## Architecture

### chezmoi Naming Conventions

| Prefix / suffix | Meaning                                              | Example                                   |
| --------------- | ---------------------------------------------------- | ----------------------------------------- |
| `dot_`          | Becomes `.` in `$HOME`                               | `dot_zshrc` → `~/.zshrc`                  |
| `private_`      | Installed with `0600` permissions                    | `private_dot_ssh/`                        |
| `encrypted_`    | Decrypted with age key on apply                      | `encrypted_private_key.age`               |
| `.tmpl`         | Go `text/template` — edit these, not `$HOME` targets | `dot_gitconfig.tmpl`                      |
| `run_once_*`    | Script runs once per machine                         | `run_once_after_install-gh-extensions.sh` |

### Responsibility Matrix

| Concern                         | Tool                                                      |
| ------------------------------- | --------------------------------------------------------- |
| Dotfiles (.zshrc, .vimrc, etc.) | chezmoi                                                   |
| SSH (~/.ssh)                    | chezmoi (`private_dot_ssh/`, encrypted with age)          |
| Secrets (~/.aws, tokens)        | `setup/symlinks.sh` (Dropbox `~/Dropbox/config`)          |
| Packages - macOS                | Homebrew + Brewfile                                       |
| Packages - Ubuntu/WSL           | Nix + home-manager                                        |
| Language runtimes               | mise (`~/.config/mise/config.toml`)                       |
| Shell configuration             | `dot_zsh/configs/` (modular by platform)                  |
| Utility scripts                 | `bin/` → `~/bin/`, `dot_local/bin/` → `~/.local/bin/`     |
| Desktop entries (Linux)         | `dot_local/share/applications/`, `dot_local/share/icons/` |
| One-time setup scripts          | `.chezmoiscripts/` (chezmoi `run_once_*`)                 |
| Key remapper (Linux/GNOME)      | xremap (`setup/setup-xremap.sh`)                          |
| macOS window manager            | Aerospace (`dot_aerospace.toml`)                          |
| GNOME extensions                | `setup/gnome-extensions.sh`                               |
| GNOME system configuration      | `setup/gnome-defaults.sh`                                 |
| Ulauncher                       | `setup/setup-ulauncher.sh`                                |
| macOS system configuration      | `setup/macos/defaults.sh`                                 |

### Nix vs mise

| Category                | Manager                             | Examples                           |
| ----------------------- | ----------------------------------- | ---------------------------------- |
| CLI tools and utilities | Nix (`nix/packages.nix`)            | bun, fzf, ripgrep, jq, gh          |
| Language runtimes       | mise (`~/.config/mise/config.toml`) | node, ruby, python, erlang, elixir |

- **Nix**: Reproducible, declarative. Good for tools where exact version doesn't matter much.
- **mise**: Tracks `latest`/`lts`, supports per-project `.mise.toml` for version switching.
  nixpkgs can lag behind on language runtimes (e.g. Ruby 3.3 when 4.0 is out).

