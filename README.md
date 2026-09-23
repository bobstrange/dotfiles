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
2. Apply dotfiles (encrypted files are skipped if the age key is not yet restored)
3. Install packages via the appropriate make target:
   - macOS: `make setup-macos` (Homebrew + mise)
   - Ubuntu (GNOME desktop): `make setup-linux` (Nix + mise + git hooks + GNOME extensions +
     Ulauncher + VS Code + xremap)
   - WSL: `make setup-wsl` (Nix + mise + git hooks — GNOME, Ulauncher, VS Code and xremap are
     skipped automatically)

Apply comes before the make targets on purpose: `mise install` reads `~/.config/mise/config.toml`,
so on an unapplied machine it installs nothing, and `lefthook-setup`'s `npm ci` then finds no node.

> **WSL:** The bootstrap script detects WSL automatically via `/proc/version` and runs
> `make setup-wsl` instead of `make setup-linux`. Set `DOTFILES_SETUP_TARGET=setup-wsl` (or
> `setup-linux`) to override the detection, e.g. on a headless Ubuntu without a GNOME session.

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
| `~/.ssh/config` | No `IdentityAgent` pin — the session's own ssh agent is used |

`~/.claude` is not part of this switch: chezmoi ignores it on every machine (see
[Claude Code config](#claude-code-config)).

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

4. Claude Code config — see [Claude Code config](#claude-code-config).

5. (Optional) Link Dropbox secrets (`~/.aws`, tokens):

```bash
make symlinks   # Requires ~/Dropbox/config
```

### Claude Code config

`~/.claude` is **not managed by chezmoi** (`.chezmoiignore` excludes it on every
machine). It is composed by the deploy tool in
[bobstrange/coding-agent-configs](https://github.com/bobstrange/coding-agent-configs)
from that public base plus private overlay repos, so nothing personal or work-specific
has to live in this public repo. Bootstrap:

```bash
ghq get bobstrange/coding-agent-configs          # base + deploy tool
# private overlays too, then list them in ~/.config/agent-configs/config.toml
# (template: coding-agent-configs/config.example.toml)
~/src/github.com/bobstrange/coding-agent-configs/bin/agent-configs apply --dry-run
~/src/github.com/bobstrange/coding-agent-configs/bin/agent-configs apply   # --force to back up what is in the way
```

`chezmoi apply` runs the same `apply` once via
`.chezmoiscripts/run_onchange_after_agent-configs-apply.sh` when the clone is present
(a missing clone or a conflict only prints a hint). After that, `apply` also links the
CLI to `~/.local/bin/agent-configs`, and a `SessionStart` hook runs `agent-configs
doctor` so drift shows up at the start of every Claude Code session.

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

#### Maintenance (all platforms)

```bash
make update           # Sweep lazy.nvim/tpm plugins, gh extensions, mise runtimes, Homebrew (macOS)
make verify           # Report drift: $HOME vs source, and uncommitted `chezmoi add`s
make bootstrap-test   # Run setup/bootstrap.sh in a fresh Ubuntu container (Linux, needs `make podman-setup`)
```

`make update` covers everything that is installed once and never re-checked. Nix is deliberately
not in it: CI updates `nix/flake.lock` weekly, so its path is `git pull && make nix-apply`.

#### Git Branch Cleanup

`dot_local/bin/` ships git subcommands that understand GitHub squash merges, which plain
`git branch --merged` cannot see:

```bash
git stale             # Local branches gone quiet, oldest first ([gone] = remote deleted, worktree holding it)
git merged            # Branches whose PR merged on GitHub, squash merges included
git delete-merged     # Delete those, refusing any branch that would strand a commit
git delete-branch B   # Same check for one branch (exit 2: commits would be lost, 3: held by a worktree)
git tidy              # fzf picker over `git stale`, with each branch's recent commits as preview
```

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

## Changing this repo

Where a new package, config or script goes, and what is owned by CI or other repos, is in
[CLAUDE.md](CLAUDE.md).
