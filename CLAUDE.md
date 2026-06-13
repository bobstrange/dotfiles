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

For cross-platform CLI tools (e.g. `markdownlint-cli2`, `dprint`), add to **both** `Brewfile` and
`nix/packages.nix`. Linux-only packages (e.g. `wl-clipboard`, `xremap`) go to `nix/packages.nix` only.

### Nix vs mise

- **Nix** (`nix/packages.nix`): CLI tools and utilities where the latest version is not critical
  (e.g. fzf, ripgrep, jq, gh, neovim)
- **mise** (`~/.config/mise/config.toml`): Language runtimes that need version switching per project
  or tracking `latest`/`lts` (e.g. node, ruby, python, erlang, elixir)

Rationale: nixpkgs can lag behind on language runtimes, while mise provides flexible version
management with `latest`, `lts`, and per-project `.mise.toml` overrides.

## Git Hooks

Pre-commit hooks are managed with lefthook (`make lefthook-setup`). Hooks run on staged files:

- **trailing-whitespace**: `git diff --check`
- **dprint-check**: format check for `*.md`, `*.json`, `*.yaml`, `*.yml`, `*.toml`
- **markdownlint**: `markdownlint-cli2` for `*.md` (120-char line limit, config in `.markdownlint-cli2.yaml`)

## Notes

- `make nix-apply` and `make nix-update` auto-commit `nix/flake.lock` if it changes
- Rollback Nix packages: `home-manager rollback`
