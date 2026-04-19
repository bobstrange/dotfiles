# Dotfiles (chezmoi)

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
| Packages - Ubuntu/WSL           | Nix + home-manager (packages + `home.sessionPath`)        |
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

### Git Hooks

Pre-commit hooks are managed with lefthook (`make lefthook-setup`). Hooks run on staged files:

- **trailing-whitespace**: `git diff --check`
- **dprint-check**: format check for `*.md`, `*.json`, `*.yaml`, `*.yml`, `*.toml`
- **markdownlint**: `markdownlint-cli2` for `*.md` (120-char line limit, config in `.markdownlint-cli2.yaml`)

`make setup-linux` includes lefthook-setup. For macOS, run `make lefthook-setup` separately.

### Utility Scripts

Scripts in `bin/` are installed to `~/bin/`, and `dot_local/bin/` to `~/.local/bin/`:

| Script                       | Location        | Description                              |
| ---------------------------- | --------------- | ---------------------------------------- |
| `claude-search-sessions.py`  | `bin/`          | Search Claude Code session logs          |
| `ghostty-wrapper`            | `bin/`          | Ghostty terminal launcher (Linux)        |
| `neovide-launcher`           | `dot_local/bin` | Neovide desktop launcher (Linux)         |
| `update-git-delta-themes.sh` | `dot_local/bin` | Update git-delta color theme definitions |

Desktop entries and icons for Linux are managed in `dot_local/share/`.

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

## Setup Flow

1. `setup/bootstrap.sh` installs chezmoi and clones this repo
2. `make setup-macos` or `make setup-linux` installs packages and applies config
3. Restore age key at `~/.config/chezmoi/key.txt` (from 1Password) for encrypted files
4. `chezmoi apply` to apply all dotfiles including encrypted ones
5. (Optional) `make symlinks` to link Dropbox secrets

## Development Notes

- Nix provides reproducible builds via `flake.lock`
- Rollback: `home-manager rollback`
- `make nix-apply` auto-commits `nix/flake.lock` if it changes — be aware of this side effect
