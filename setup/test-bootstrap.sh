#!/usr/bin/env bash
# Run setup/bootstrap.sh for real, in a fresh Ubuntu container, and check what
# it leaves behind.
#
# "If this machine dies, bootstrap.sh + make setup-* rebuilds it" is the claim
# this repo rests on, and until this existed it had never been exercised: the
# script was written on a machine that was already set up. This is the test.
#
# Why podman with systemd as PID 1, and not `container:` in Actions or a bare
# runner: the Determinate Nix installer wants systemd, and a bare runner already
# has git, npm and node, which is exactly what bootstrap.sh must be shown not to
# need. The container is built from ubuntu:26.04 with only what Ubuntu Desktop
# ships (systemd, sudo, curl) — no git, no make, no jq.
#
# The checkout is a clone of this repo's HEAD, with its origin rewritten to a
# bare copy inside the container. That keeps a dirty working tree out of the
# picture (so `make verify` means something) and lets check-lock-drift.sh reach
# "origin" without SSH keys. `chezmoi init` then sees an existing repo and only
# regenerates the config.
#
# Assertions are evaluated independently of bootstrap's exit code: a red
# `mise install` (erlang failing to build on a new release, say) is information
# from upstream and must not hide a red in what this repo owns.
#
# Usage: make bootstrap-test [ARGS=--keep]
#   --keep   leave the container running for inspection
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="localhost/dotfiles-bootstrap-test"
CONTAINER="dotfiles-bootstrap-test"
# tmp/ is in .gitignore
LOG_DIR="${BOOTSTRAP_TEST_LOG_DIR:-$REPO_DIR/tmp/bootstrap-test}"
USER_NAME="bob"
USER_HOME="/home/$USER_NAME"
CHEZMOI_DIR="$USER_HOME/.local/share/chezmoi"
ORIGIN_DIR="$USER_HOME/.local/share/dotfiles-origin.git"

KEEP=false
for arg in "$@"; do
  case "$arg" in
    --keep) KEEP=true ;;
    *) echo "Usage: $0 [--keep]" >&2; exit 2 ;;
  esac
done

section() { printf '\n==> %s\n' "$1"; }

# --- Preconditions ---------------------------------------------------------

if ! command -v podman >/dev/null 2>&1; then
  echo "podman not found. Install it with: make podman-setup" >&2
  exit 1
fi

# Ubuntu 24.04+ blocks unprivileged user namespaces unless an AppArmor profile
# allows them. apt's podman ships one; a podman from elsewhere may not, and the
# symptom is `podman run` failing on the user namespace, not a clear message.
if [ "$(cat /proc/sys/kernel/apparmor_restrict_unprivileged_userns 2>/dev/null)" = "1" ] \
  && [ ! -e /etc/apparmor.d/podman ]; then
  echo "warning: apparmor_restrict_unprivileged_userns=1 and no AppArmor profile for podman;" >&2
  echo "         rootless containers may fail to start. Use apt's podman (make podman-setup)." >&2
fi

mkdir -p "$LOG_DIR"
WORK="$(mktemp -d)"
# shellcheck disable=SC2329  # invoked by the EXIT trap
cleanup() {
  rm -rf "$WORK"
  if [ "$KEEP" != true ]; then
    podman rm -f "$CONTAINER" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

# --- Image -----------------------------------------------------------------

section "Building $IMAGE"
# The stock image has an `ubuntu` user at uid 1000; drop it so bob gets 1000
# like on a real install. apt lists are deliberately not removed: a machine
# straight after install has them, and bootstrap.sh's `apt-get install make`
# relies on that (it does not run `apt-get update`).
cat > "$WORK/Containerfile" <<'CONTAINERFILE'
FROM docker.io/library/ubuntu:26.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends systemd systemd-sysv sudo curl ca-certificates \
 && userdel -r ubuntu 2>/dev/null || true \
 && useradd -m -s /bin/bash -u 1000 bob \
 && echo 'bob ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/bob \
 && chmod 440 /etc/sudoers.d/bob
CMD ["/sbin/init"]
CONTAINERFILE
podman build -q -t "$IMAGE" -f "$WORK/Containerfile" "$WORK" >/dev/null

# --- Container -------------------------------------------------------------

section "Starting $CONTAINER"
podman rm -f "$CONTAINER" >/dev/null 2>&1 || true
podman run -d --name "$CONTAINER" --systemd=always "$IMAGE" >/dev/null
# Give systemd a moment to reach a usable state before anything calls systemctl.
for _ in $(seq 1 30); do
  if podman exec "$CONTAINER" systemctl is-system-running --wait >/dev/null 2>&1; then break; fi
  sleep 1
done

section "Seeding the checkout ($(git -C "$REPO_DIR" rev-parse --abbrev-ref HEAD) @ $(git -C "$REPO_DIR" rev-parse --short HEAD))"
git clone --quiet --bare "$REPO_DIR" "$WORK/origin.git"
# A bare clone copies local branches only. check-lock-drift.sh fetches
# `origin main`, so make sure the bare repo has one — on a CI runner the
# checkout is a detached HEAD with main only as a remote-tracking ref.
main_ref="$(git -C "$REPO_DIR" rev-parse --verify -q refs/remotes/origin/main \
  || git -C "$REPO_DIR" rev-parse --verify -q refs/heads/main)" \
  || { echo "neither origin/main nor main found in $REPO_DIR" >&2; exit 1; }
git -C "$WORK/origin.git" update-ref refs/heads/main "$main_ref"
git -c advice.detachedHead=false clone --quiet "$WORK/origin.git" "$WORK/chezmoi"
git -C "$WORK/chezmoi" remote set-url origin "$ORIGIN_DIR"
podman exec "$CONTAINER" mkdir -p "$USER_HOME/.local/share"
podman cp "$WORK/origin.git" "$CONTAINER:$ORIGIN_DIR"
podman cp "$WORK/chezmoi" "$CONTAINER:$CHEZMOI_DIR"
podman exec "$CONTAINER" chown -R "$USER_NAME:$USER_NAME" "$USER_HOME"

# --- Run bootstrap ---------------------------------------------------------

# Non-interactive, no login shell: exactly what `curl | bash` gets.
# erlang/elixir are left out: erlang is a multi-minute source build whose
# outcome depends on upstream and the build environment, not on anything this
# test is about (bootstrap's ordering and what it leaves behind). node stays
# in — lefthook-setup depends on it.
run_bootstrap() {
  podman exec -u "$USER_NAME" -w "$USER_HOME" \
    -e HOME="$USER_HOME" -e USER="$USER_NAME" -e DOTFILES_SETUP_TARGET=setup-wsl \
    -e MISE_DISABLE_TOOLS=erlang,elixir \
    "$CONTAINER" bash "$CHEZMOI_DIR/setup/bootstrap.sh"
}

section "Running bootstrap.sh (1st run) — log: $LOG_DIR/bootstrap-1.log"
set +e
run_bootstrap 2>&1 | tee "$LOG_DIR/bootstrap-1.log"
BOOTSTRAP1_STATUS=${PIPESTATUS[0]}
set -e
echo "bootstrap.sh exited with $BOOTSTRAP1_STATUS"

section "Running bootstrap.sh (2nd run, idempotency) — log: $LOG_DIR/bootstrap-2.log"
set +e
run_bootstrap 2>&1 | tee "$LOG_DIR/bootstrap-2.log"
BOOTSTRAP2_STATUS=${PIPESTATUS[0]}
set -e
echo "bootstrap.sh exited with $BOOTSTRAP2_STATUS"

# --- Assertions ------------------------------------------------------------

# Everything is checked from inside nix's zsh, as an interactive shell, so the
# .zshenv → .zshrc → mise activate chain is itself under test. `podman exec`
# alone has a bare PATH, and nothing here runs chsh, so the daemon profile is
# sourced first purely to find zsh.
in_zsh() {
  podman exec -u "$USER_NAME" -w "$USER_HOME" -e HOME="$USER_HOME" -e USER="$USER_NAME" \
    -e EVAL_SHELL="$EVAL_SHELL" \
    "$CONTAINER" bash -c '. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh && exec "$EVAL_SHELL" -ic "$1"' _ "$1" 2>/dev/null
}

failures=0
total=0
pass() { printf '  ✅ %s\n' "$1"; total=$((total + 1)); }
fail() { printf '  ❌ %s\n' "$1"; total=$((total + 1)); failures=$((failures + 1)); }

# If home-manager never switched there is no zsh to evaluate in. Fall back to
# bash so the remaining checks still describe the machine instead of all
# failing for the same reason.
section "evaluation shell"
EVAL_SHELL=zsh
if in_zsh 'true' >/dev/null; then
  pass "nix's zsh is on PATH"
else
  fail "nix's zsh is on PATH (falling back to bash for the checks below)"
  EVAL_SHELL=bash
fi
check() { # check <description> <zsh command that exits 0 on success>
  if in_zsh "$2" >/dev/null; then pass "$1"; else fail "$1"; fi
}
check_log() { # check_log <description> <logfile> <pattern>
  if grep -q -- "$3" "$2"; then pass "$1"; else fail "$1"; fi
}

section "age fallback"
check_log "bootstrap warned that the age key is missing" "$LOG_DIR/bootstrap-1.log" "age key not found"
check "encrypted target ~/.ssh/config.d/work.conf was skipped" '[ ! -e ~/.ssh/config.d/work.conf ]'
check "plain template ~/.ssh/config was written" '[ -f ~/.ssh/config ]'

section "generated files"
check "chezmoi.toml was generated" '[ -f ~/.config/chezmoi/chezmoi.toml ]'
check ".zshrc was applied" '[ -f ~/.zshrc ]'

section "tools resolve to the nix store"
# `mise activate` wraps mise in a shell function, so `command -v` would
# report the function; whence -p (zsh) / type -P (bash) give the file.
for tool in zsh mise lefthook starship rg git; do
  check "$tool" "p=\$(whence -p $tool 2>/dev/null || type -P $tool) && case \$(readlink -f \"\$p\") in /nix/store/*) ;; *) exit 1 ;; esac"
done

section "runtimes"
# shellcheck disable=SC2016  # expanded inside the container's zsh, not here
check "mise installed node" '[ -n "$(mise ls --installed node 2>/dev/null)" ]'
# shellcheck disable=SC2016
check "npm resolves through mise" 'case $(command -v npm) in */.local/share/mise/*) ;; *) exit 1 ;; esac'
printf '  ℹ️  mise ls --installed (erlang/elixir disabled for this test):\n'
in_zsh 'mise ls --installed' | sed 's/^/        /' || true

section "drift"
check "make verify exits 0" "cd $CHEZMOI_DIR && make verify"
check_log "2nd run's lock drift check reached origin" "$LOG_DIR/bootstrap-2.log" "flake.lock: up to date with origin/main"

section "idempotency"
if [ "$BOOTSTRAP2_STATUS" -eq 0 ]; then
  pass "2nd bootstrap.sh exited 0"
else
  fail "2nd bootstrap.sh exited $BOOTSTRAP2_STATUS"
fi

# --- Summary ---------------------------------------------------------------

section "Summary"
echo "  bootstrap.sh exit: 1st=$BOOTSTRAP1_STATUS 2nd=$BOOTSTRAP2_STATUS"
[ "$BOOTSTRAP1_STATUS" -eq 0 ] || echo "  note: 1st run's non-zero exit is not an assertion; see $LOG_DIR/bootstrap-1.log"
echo "  logs: $LOG_DIR"
if [ "$KEEP" = true ]; then
  printf '  container kept:\n    podman exec -it -u %s -w %s %s bash\n    podman rm -f %s\n' \
    "$USER_NAME" "$USER_HOME" "$CONTAINER" "$CONTAINER"
fi

# The verdict is the last line on purpose, so it is what the eye lands on.
echo ""
if [ "$failures" -eq 0 ]; then
  echo "✅ bootstrap smoke test: $total/$total assertions passed"
  exit 0
else
  echo "❌ bootstrap smoke test: $failures/$total assertions failed"
  exit 1
fi
