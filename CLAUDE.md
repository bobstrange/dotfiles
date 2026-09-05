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

## CI

Lint checks live in `.github/workflows/lint.yml`. Most of it is one caller job:

- **`lint`** — `uses: bobstrange/gh-workflows/.github/workflows/lint.yml@v1`, reporting as
  `lint / lint`. It runs shellcheck, yamllint, markdownlint, actionlint, prettier and secretlint in
  a single job, using this repo's configs and `package.json` pins (`.node-version` picks the node
  major, so local mise and CI agree). Same source as the pre-commit hooks, so a `--no-verify`
  commit is still caught. Changing a linter means releasing a new `v1.x.y` in gh-workflows

Four repo-specific jobs stay here, because nothing shared can express them:

- **zsh syntax check**: `zsh -n` over `dot_zsh/**/*.zsh`
- **chezmoi templates**: `chezmoi apply --dry-run --force --exclude encrypted` on ubuntu **and**
  macOS, since several templates branch on `.chezmoi.os`. `--exclude encrypted` is required because
  the age identity is not in CI
- **nix eval**: `nix flake check --no-build` plus a full eval of each `homeConfigurations`
  activation package, to catch `nix/packages.nix` typos before `make nix-apply` hits them
- **nix build** (`.github/workflows/nix-build.yml`): actually builds
  `homeConfigurations."bob@ubuntu".activationPackage`, since evaluation cannot see a package that
  builds badly (a failing test, an unappliable patch, a stale hash). That closure is ~7 GiB, so the
  job runs on every PR but skips the build unless `nix/flake.lock` or `nix/flake.nix` changed —
  seconds otherwise. It deliberately has **no `paths:` filter**: a workflow that never triggers
  leaves its checks pending forever, which cannot be a required check and would stop auto-merge
  from waiting on it

### flake.lock updates

`.github/workflows/nix-flake-update.yml` runs `nix flake update` weekly (Monday 09:00 JST) and
opens one PR, which merges itself once the checks pass. `nix build` above is what makes merging it
unattended defensible.

- it writes through a **GitHub App** token (`bobstrange-automation`, `AUTOMATION_APP_ID` /
  `AUTOMATION_APP_PRIVATE_KEY`), because PRs created with `GITHUB_TOKEN` do not start workflow
  runs — the required checks would sit pending and `--auto` would wait forever
- one branch, `automated/flake-lock`, is reused and force-pushed, so an unmerged update is replaced
  instead of accumulating PRs
- `make nix-apply` refuses to run when `nix/flake.lock` is behind `origin/main`
  (`setup/check-lock-drift.sh`), since a machine that has not pulled would otherwise install older
  versions silently. `SKIP_LOCK_DRIFT_CHECK=1` overrides it

### Dependabot auto-merge

`.github/workflows/dependabot-auto-merge.yml` queues `gh pr merge --auto` on Dependabot PRs, but
**only for patch/minor** — majors stay manual. The waiting is done by the repo ruleset
**"main: require Lint checks"**, which marks every Lint job as required on `main`; without those
required checks `--auto` would merge immediately instead of waiting. Two consequences:

- **renaming a Lint job breaks every PR** until the ruleset's context list is updated to match —
  this includes the shared job, required as `lint / lint`, so a job rename in gh-workflows is a
  breaking change there (`v2`)
- direct pushes to `main` must also satisfy the checks (repo admin has an `always` bypass)

## Notes

- `make nix-apply` and `make nix-update` auto-commit `nix/flake.lock` if it changes. Routine
  updates are CI's job now (see **flake.lock updates**); `make nix-update` is for when you need
  one immediately
- Rollback Nix packages: `home-manager rollback`
