---
paths:
  - ".github/**"
  - "nix/**"
  - "Makefile"
---

# CI

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

`.github/workflows/bootstrap-smoke.yml` holds two more, on the `ubuntu-26.04` runner. Both
have a `paths:` filter (everything that can change bootstrap's outcome) plus a weekly schedule,
so for the reason just given neither is a required check:

- **bootstrap smoke test**: `make bootstrap-test` (see `.claude/rules/bootstrap.md`), logs uploaded as an
  artifact. Hosted runners only: the Determinate installer and the AppArmor sysctl leave marks
  on the host
- **ubuntu 26.04 package availability**: `apt-cache policy ghostty` into the step summary, a
  warning when absent. Groundwork for issue #53, never a failure

## flake.lock updates

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

## Dependabot auto-merge

`.github/workflows/dependabot-auto-merge.yml` queues `gh pr merge --auto` on Dependabot PRs, but
**only for patch/minor** — majors stay manual. The waiting is done by the repo ruleset
**"main: require Lint checks"**, which marks every Lint job as required on `main`; without those
required checks `--auto` would merge immediately instead of waiting. Two consequences:

- **renaming a Lint job breaks every PR** until the ruleset's context list is updated to match —
  this includes the shared job, required as `lint / lint`, so a job rename in gh-workflows is a
  breaking change there (`v2`)
- direct pushes to `main` must also satisfy the checks (repo admin has an `always` bypass)
