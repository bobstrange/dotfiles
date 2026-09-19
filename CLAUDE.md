# Dotfiles (chezmoi)

Supports macOS, Ubuntu, and WSL. Run `make help` for available targets.

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

### VS Code (apt, not nix)

VS Code is the one package installed with apt (`make vscode-setup`,
`setup/setup-vscode.sh`), against the global "no apt" rule. nixpkgs' `vscode` is unfree, so
it is absent from `cache.nixos.org` and the `nix build` CI job would re-download ~330MB on
every run; worse, extensions that fetch their own binaries (pylance, java, terraform,
copilot) need the `vscode-fhs` wrapper to work off NixOS. Microsoft's apt repository has
neither problem and publishes new releases same-day, so `apt upgrade` keeps it current.

**Extensions are not managed here.** They belong to Settings Sync, along with keybindings,
snippets, tasks, MCP servers, UI state, profiles and prompts. The `vscode "..."` lines that used
to be in `Brewfile` were a snapshot that had not been touched in 16 months — by the time they
were deleted the real set differed by 20 entries — and `brew bundle` reinstalled extensions that
Settings Sync had removed. Do not add them back to `Brewfile` or `nix/packages.nix`; whichever
ran last would win.

`settings.json` is the exception and _is_ managed here, on Linux only. Its add-back workflow
(edit `$HOME` target → `chezmoi add`) and its gotchas — the `private_` prefix, the JSONC/prettier
conflict, and the one-time GUI step that turns Settings sync off — live in
`.claude/rules/vscode.md`, loaded automatically when working under `dot_config/private_Code/`.

### podman (apt, not nix)

podman is the other apt exception (`make podman-setup`, `setup/setup-podman.sh`): nixpkgs'
podman has no AppArmor profile, so Ubuntu refuses it rootless user namespaces, and rootless
mode needs apt's setuid `uidmap` anyway. It exists only for `make bootstrap-test` and is not
part of `setup-linux`.

### package.json

`package.json` holds dev tooling for **this repo only** (prettier, secretlint) — it is never installed
to `$HOME`, and `.chezmoiignore` excludes it along with `package-lock.json` and `node_modules/`.
It exists so the pre-commit hook and CI resolve the identical pinned binary, and so Dependabot can
propose upgrades. Run `npm ci` after cloning.

## Zed

Zed's add-back workflow (edit `$HOME` target → `chezmoi add`) and its gotchas live in
`.claude/rules/zed.md`, loaded automatically when working under `dot_config/zed/`.

## Git Hooks

Pre-commit hooks are managed with lefthook (`make lefthook-setup`). `lefthook.yml` is plain,
checked-in YAML that pulls every hook from **[bobstrange/gh-workflows](https://github.com/bobstrange/gh-workflows)**
via `remotes:` (`ref: v1`, refetched every 24h — `v1` is a moving tag). Hooks run on staged files:
trailing whitespace, prettier, markdownlint, shellcheck, yamllint, secretlint (all named
`common-*`). To change one, change it in gh-workflows and cut a release there — not here.

- This repo's configs win over the shared fallbacks: `.prettierignore`,
  `.markdownlint-cli2.yaml`, `.yamllint.yml`, `.secretlintrc.json`
- prettier / secretlint resolve `node_modules/.bin`, pinned in `package.json`, so run `npm ci`
  (included in `make lefthook-setup`) or they fall back to the shared inline pins
- `~/.config/lefthook/lefthook.yml` (shipped by this repo via chezmoi) is deliberately **not**
  extended here — it exists for repos that are not on the shared standard, and its secretlint
  would double-run against `common-secretlint`

## Keeping things current

`make update` (`setup/update.sh`) sweeps everything that is installed once and then never
moves on its own: lazy.nvim plugins, tpm plugins, gh extensions, mise runtimes, and Homebrew
on macOS. These bootstrap with "clone if absent" (`plugins.conf`) or `run_once_`
(`.chezmoiscripts/`), so nothing re-checks them afterwards — a plugin cloned at setup stays at
that commit until something breaks. Nix is the exception and is deliberately not in the script:
CI owns `nix/flake.lock` (see **flake.lock updates** in `.claude/rules/ci.md`), so its update path is
`git pull && make nix-apply`. APT is out of scope too — it only holds the base Ubuntu system,
covered by unattended-upgrades plus the `apt-update` alias. The script prints a pointer for both.

`lazy-lock.json` is not a pin — lazy.nvim rewrites it after every install/update and only reads
it back on `:Lazy restore`. It is in `.chezmoiignore` because update timing is per-machine.

## Notes

- `make nix-apply` leaves a changed `nix/flake.lock` uncommitted and warns. Updating the lock is CI's job
  (see **flake.lock updates** in `.claude/rules/ci.md`) — there is deliberately no local update target. To pull an update
  in before Monday, run the `Update flake.lock` workflow by hand (`workflow_dispatch`), so it
  still goes through `nix build` and the same pull request
- Rollback Nix packages: `home-manager rollback`
