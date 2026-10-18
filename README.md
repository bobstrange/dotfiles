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

`make help` lists every target. What it does not say:

- `make setup-macos` does not include `lefthook-setup`; run `make lefthook-setup` once after it.
- `make update` leaves Nix out on purpose: CI updates `nix/flake.lock` weekly, so the Nix path
  is `git pull && make nix-apply`. Outside make: `nix search nixpkgs <name>`,
  `home-manager rollback`.
- Docker disk cleanup (Ubuntu) ships as a systemd user timer that has to be enabled once; see
  `docker-disk-cleanup --help` for what it prunes and when.

  ```bash
  systemctl --user daemon-reload
  systemctl --user enable --now docker-disk-cleanup.timer
  ```

- `dot_local/bin/` ships git subcommands that understand GitHub squash merges (`git stale`,
  `git merged`, `git delete-merged`, `git delete-branch`, `git tidy`); each script's header
  describes it.

### Git Hooks

[lefthook](https://github.com/evilmartians/lefthook) runs pre-commit checks after
`make lefthook-setup` (included in `make setup-linux` and `make setup-wsl`). The hooks live in
[bobstrange/gh-workflows](https://github.com/bobstrange/gh-workflows) and are pulled in by
`lefthook.yml` as a remote config, so they match CI exactly.

## Changing this repo

Where a new package, config or script goes, and what is owned by CI or other repos, is in
[CLAUDE.md](CLAUDE.md).
