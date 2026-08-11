# Dotfiles (chezmoi)

Supports macOS, Ubuntu, and WSL. Run `make help` for available targets.

## chezmoi Naming Conventions

| Prefix / suffix | Meaning                                              | Example                                   |
| --------------- | ---------------------------------------------------- | ----------------------------------------- |
| `dot_`          | Becomes `.` in `$HOME`                               | `dot_zshrc` → `~/.zshrc`                  |
| `private_`      | Installed with `0600` permissions                    | `private_dot_ssh/`                        |
| `encrypted_`    | Decrypted with age key on apply                      | `encrypted_private_key.age`               |
| `.tmpl`         | Go `text/template` — edit these, not `$HOME` targets | `dot_gitconfig.tmpl`                      |
| `run_once_*`    | Script runs once per machine                         | `run_once_after_install-gh-extensions.sh` |

## Package Management

### Adding Packages

- **macOS**: Edit `Brewfile`, run `make macos-apply`
- **Ubuntu/WSL**: Edit `nix/packages.nix`, run `make nix-apply`

For cross-platform CLI tools (e.g. `markdownlint-cli2`), add to **both** `Brewfile` and
`nix/packages.nix`. Linux-only packages (e.g. `wl-clipboard`, `xremap`) go to `nix/packages.nix` only.

### Nix vs mise

- **Nix** (`nix/packages.nix`): CLI tools and utilities where the latest version is not critical
  (e.g. fzf, ripgrep, jq, gh, neovim)
- **mise** (`~/.config/mise/config.toml`): Language runtimes that need version switching per project
  or tracking `latest`/`lts` (e.g. node, ruby, python, erlang, elixir)

Rationale: nixpkgs can lag behind on language runtimes, while mise provides flexible version
management with `latest`, `lts`, and per-project `.mise.toml` overrides. mise's npm backend also
covers CLIs that nixpkgs does not package at all (e.g. `"npm:vercel"`).

### package.json

`package.json` holds dev tooling for **this repo only** (currently prettier) — it is never installed
to `$HOME`, and `.chezmoiignore` excludes it along with `package-lock.json` and `node_modules/`.
It exists so the pre-commit hook and CI resolve the identical pinned binary, and so Dependabot can
propose upgrades. Run `npm ci` after cloning.

## Zed (add-back workflow)

`dot_config/zed/` is the one place where editing the `$HOME` target directly is correct. Zed
rewrites `~/.config/zed/settings.json` itself whenever a setting is changed from the UI (font size,
theme picker, vim mode), so the loop is reversed:

1. Change settings in Zed / `~/.config/zed/settings.json` as usual
2. `chezmoi add ~/.config/zed/settings.json`
3. `chezmoi diff` and commit

Keep these as plain JSON — promoting one to `.tmpl` breaks `chezmoi add`, so only do that once a
setting genuinely differs per machine. Extensions are declarative via `auto_install_extensions` in
`settings.json`; there is no `run_once_` install script. `~/.local/share/zed/` (DB, logs, extension
binaries, agent history) is state, not config, and stays unmanaged. `.config/zed/` is in
`.prettierignore` so Zed's own formatting of the JSONC does not ping-pong with prettier.

## Git Hooks

Pre-commit hooks are managed with lefthook (`make lefthook-setup`). `lefthook.yml` is **generated
per machine** from the chezmoi template `dot_local/share/chezmoi/lefthook.yml.tmpl` and gitignored —
lefthook does not expand `~`/`$HOME` in `extends:`, so the path to the global config
(`~/.config/lefthook/lefthook.yml`, which adds secretlint) must be absolute. Edit the template, not
`lefthook.yml`, then `chezmoi apply`. Hooks run on staged files:

- **trailing-whitespace**: `git diff --check`
- **prettier-check**: format check for `*.md`, `*.json`, `*.yaml`, `*.yml` (app-managed files are
  excluded via `.prettierignore`). Resolves `node_modules/.bin/prettier`, pinned in `package.json`,
  so run `npm ci` (included in `make lefthook-setup`) or the hook cannot find it
- **markdownlint**: `markdownlint-cli2` for `*.md` (120-char line limit, config in `.markdownlint-cli2.yaml`)
- **secretlint** (from the global config): secret scanning via npx

## CI

All checks live in `.github/workflows/lint.yml`. Beyond the linters (shellcheck, yamllint,
markdownlint, secretlint, `zsh -n`, actionlint), three jobs guard things the hooks cannot:

- **prettier**: `npm ci && npm run format:check`, i.e. the same pinned binary and globs as the
  pre-commit hook, so a `--no-verify` commit still gets caught
- **chezmoi templates**: `chezmoi apply --dry-run --force --exclude encrypted` on ubuntu **and**
  macOS, since several templates branch on `.chezmoi.os`. `--exclude encrypted` is required because
  the age identity is not in CI
- **nix eval**: `nix flake check --no-build` plus a full eval of each `homeConfigurations`
  activation package, to catch `nix/packages.nix` typos before `make nix-apply` hits them

## Notes

- `make nix-apply` and `make nix-update` auto-commit `nix/flake.lock` if it changes
- Rollback Nix packages: `home-manager rollback`
