# Dotfiles (chezmoi)

macOS, Ubuntu and WSL. Setup and daily commands are in README; `make help` lists targets.
This file says where a change goes and what is owned elsewhere.

## Where a new thing goes

| What                                          | Where                                                                                                                                   | Apply with                            |
| --------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------- |
| CLI tool, any recent version is fine          | `nix/packages.nix` **and** `Brewfile`; Linux-only tools in nix only                                                                     | `make nix-apply` / `make macos-apply` |
| Language runtime, or an npm CLI nixpkgs lacks | `dot_config/mise/config.toml` (`latest`/`lts`, per-project overrides)                                                                   | `make mise-install`                   |
| Config file                                   | chezmoi source; `.tmpl` only once it differs per OS or machine                                                                          | `chezmoi apply`                       |
| One-time side effect of an applied file       | `.chezmoiscripts/run_once_*` / `run_onchange_*`                                                                                         | `chezmoi apply`                       |
| Package nix and brew cannot deliver           | `setup/setup-<name>.sh` plus a Makefile target, the why in the script header; add to `setup-linux` only if every Linux desktop needs it | `make bootstrap-test` must stay green |
| Secret                                        | `encrypted_` (age) in the source, or a Dropbox symlink via `setup/symlinks.sh`                                                          | `chezmoi apply` / `make symlinks`     |

Current apt exceptions: VS Code (`setup/setup-vscode.sh`) and podman (`setup/setup-podman.sh`).
VS Code extensions belong to Settings Sync; never list them in `Brewfile` or nix.

chezmoi prefixes: `dot_` → leading dot, `private_` → mode 0600, `encrypted_` → age, `.tmpl` → Go template.

## Owned elsewhere — do not edit here

- `nix/flake.lock`: CI updates it weekly by PR. `make nix-apply` refuses to run behind
  `origin/main`; the only local change is the one made by adding a flake input
- Git hooks: `lefthook.yml` pulls them from bobstrange/gh-workflows. Change them there and cut
  a release. Do not extend `~/.config/lefthook/lefthook.yml` here (its secretlint would run twice)
- `~/.claude`: composed by `agent-configs apply`; `.chezmoiignore` excludes it
- `package.json`: lint pins for this repo only, never installed to `$HOME`; `npm ci` after clone

## Rules

`.claude/rules/` loads by path: `bootstrap.md`, `ci.md`, `vscode.md`, `zed.md`.
