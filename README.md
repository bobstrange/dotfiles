# dotfiles

## Tools

- **[chezmoi](https://www.chezmoi.io/)**: Dotfile management
- **[Homebrew](https://brew.sh/) + Brewfile**: Package management (macOS)
- **[Nix Flakes][nix] + [home-manager][hm]**: Package management (Ubuntu/WSL)
- **[mise](https://mise.jdx.dev/)**: Language runtime version management
- **[winget](https://learn.microsoft.com/windows/package-manager/)**: Package management (Windows)

[nix]: https://nixos.wiki/wiki/Flakes
[hm]: https://github.com/nix-community/home-manager

Supports macOS, Ubuntu, WSL, and Windows environments.

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

### Windows

Windows apps are installed via setup.ps1. Dotfiles/chezmoi are managed inside WSL — not on the
Windows side.

1. Open PowerShell as Administrator and run setup.ps1 directly from GitHub (no clone needed):

```powershell
irm -Headers @{"Cache-Control"="no-cache"} https://raw.githubusercontent.com/bobstrange/dotfiles/main/setup/windows/setup.ps1 | iex
```

> **Administrator required:** WSL installation needs elevated privileges. Right-click PowerShell
> and select "Run as administrator".

If WSL is not yet installed, the script installs WSL + Ubuntu and prompts for a reboot.
Re-run the script after rebooting to install Windows apps.

This installs apps via winget (git, Neovim, VSCode, Chrome, Vivaldi, Slack, Discord, etc.).
Apps not registered in winget are listed at the end of the script output.

2. Set up dotfiles inside WSL using the standard bootstrap script:

```bash
curl -fsLS https://raw.githubusercontent.com/bobstrange/dotfiles/main/setup/bootstrap.sh | bash
```

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

| Area            | `work = true` behaviour                                      |
| --------------- | ------------------------------------------------------------ |
| `dot_claude/`   | Skipped — `~/.claude/` is managed by agent-configs symlinks  |
| `~/.ssh/config` | No `IdentityAgent` pin — the session's own ssh agent is used |

The answer is stored as a marker file, `~/.config/chezmoi/work-machine`, which
`.chezmoi.toml.tmpl` reads. It deliberately lives **outside**
`~/.config/chezmoi/chezmoi.toml`: that file is regenerated from the template by every
`chezmoi init`, so a value written into it directly would be lost — along with the `age`
encryption settings, if something overwrote the file wholesale. Using a file rather than a
`promptBool` also keeps `chezmoi init` non-interactive for `curl | bash` bootstraps and CI.

3. Turn on Settings Sync in VS Code, with **Settings** unchecked:

Open VS Code, run `Backup and Sync Settings...` from the command palette (it is no longer
called `Settings Sync: Turn On`), sign in with GitHub, and **uncheck Settings** in the
resource list. Everything else — Keyboard Shortcuts, Snippets, Tasks, MCP Servers, UI State,
Extensions, Profiles, Prompts — stays checked.

This cannot be scripted: the per-resource toggle lives in `globalStorage/state.vscdb`
(SQLite) as `sync.enable.settings`, and VS Code exposes no setting id for it. Skipping the
step leaves the cloud copy of `settings.json` fighting the one this repo installs.

4. (Optional) Link Dropbox secrets (`~/.aws`, tokens):

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
make nix-apply        # After editing nix/*.nix files (warns if nix/flake.lock moved; CI owns it)
nix search nixpkgs <package-name>  # Search for packages
home-manager rollback              # Rollback to previous generation
```

On Ubuntu (GNOME desktop) only:

```bash
make gnome-defaults   # Apply GNOME system preferences
```

#### Docker Disk Cleanup (Ubuntu, systemd user timer)

`docker-disk-cleanup.timer` prunes Docker build cache and images older than 30 days, but only
when `/` usage is at or above 70%. It never touches volumes, containers, `~/.config`, browser
data, or project build artifacts.

```bash
systemctl --user daemon-reload
systemctl --user enable --now docker-disk-cleanup.timer
systemctl --user list-timers docker-disk-cleanup.timer

docker-disk-cleanup --check   # report what would happen; deletes nothing
docker-disk-cleanup --help    # full option/threshold reference
```

Runs monthly (1st, 03:00 JST regardless of host timezone, `Persistent=true` to catch up if the
machine was off). Logs to `~/.local/state/docker-disk-cleanup/cleanup.log` (unmanaged by chezmoi).

### Adding Packages

- **macOS**: Edit `Brewfile`, run `make macos-apply`
- **Ubuntu/WSL**: Edit `nix/packages.nix`, run `make nix-apply`

### Git Hooks

[lefthook](https://github.com/evilmartians/lefthook) runs pre-commit checks automatically after
`make lefthook-setup` (included in `make setup-linux` and `make setup-wsl`). The hooks themselves
live in [bobstrange/gh-workflows](https://github.com/bobstrange/gh-workflows) and are pulled in by
`lefthook.yml` as a remote config, so they match CI exactly:

| Hook                       | Files                               | Tool                |
| -------------------------- | ----------------------------------- | ------------------- |
| common-trailing-whitespace | all staged files                    | `git diff --check`  |
| common-prettier            | `*.md`, `*.json`, `*.yaml`, `*.yml` | `prettier`          |
| common-markdownlint        | `*.md`                              | `markdownlint-cli2` |
| common-shellcheck          | `*.sh`, `*.bash`                    | `shellcheck`        |
| common-yamllint            | `*.yml`, `*.yaml`                   | `yamllint`          |
| common-secretlint          | all staged files                    | `secretlint`        |

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

| Concern                             | Tool                                       |
| ----------------------------------- | ------------------------------------------ |
| Dotfiles (.zshrc, .gitconfig, etc.) | chezmoi                                    |
| SSH (~/.ssh)                        | chezmoi (encrypted with age)               |
| Secrets (~/.aws, tokens)            | Dropbox symlinks (`setup/symlinks.sh`)     |
| Packages - macOS                    | Homebrew + Brewfile                        |
| Packages - Ubuntu/WSL               | Nix + home-manager                         |
| Language runtimes                   | mise                                       |
| Shell configuration                 | `dot_zsh/configs/`                         |
| VS Code settings (Linux)            | chezmoi (`dot_config/private_Code/`)       |
| VS Code extensions, keybindings     | Settings Sync                              |
| Docker disk cleanup (Ubuntu)        | systemd user timer (`docker-disk-cleanup`) |

### Nix vs mise

| Category                | Manager                             | Examples                           |
| ----------------------- | ----------------------------------- | ---------------------------------- |
| CLI tools and utilities | Nix (`nix/packages.nix`)            | bun, fzf, ripgrep, jq, gh          |
| Language runtimes       | mise (`~/.config/mise/config.toml`) | node, ruby, python, erlang, elixir |

- **Nix**: Reproducible, declarative. Good for tools where exact version doesn't matter much.
- **mise**: Tracks `latest`/`lts`, supports per-project `.mise.toml` for version switching.
  nixpkgs can lag behind on language runtimes (e.g. Ruby 3.3 when 4.0 is out).
