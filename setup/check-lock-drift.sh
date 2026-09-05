#!/usr/bin/env bash
# Refuses to apply a home-manager configuration whose flake.lock is behind
# origin/main.
#
# CI updates the lock on its own schedule now, so a machine that has not
# pulled will happily apply an older lock and end up on different package
# versions than the other one, with nothing to show that it happened. This
# turns that silent drift into a stop.
#
# It is a guard, not a gate: running `home-manager switch` directly walks
# straight past it.
set -euo pipefail

LOCK="nix/flake.lock"

if [ -n "${SKIP_LOCK_DRIFT_CHECK:-}" ]; then
  echo "flake.lock: drift check skipped (SKIP_LOCK_DRIFT_CHECK is set)"
  exit 0
fi

# Being offline is a bad reason to refuse to apply anything.
if ! git fetch --quiet origin main 2>/dev/null; then
  echo "flake.lock: could not reach origin, skipping the drift check" >&2
  exit 0
fi

# Having origin/main in your history means the lock is either main's or
# deliberately ahead of it — an update branch, say.
if git merge-base --is-ancestor origin/main HEAD; then
  echo "flake.lock: up to date with origin/main"
  exit 0
fi

if git diff --quiet origin/main HEAD -- "$LOCK"; then
  echo "flake.lock: behind origin/main, but the lock itself is unchanged"
  exit 0
fi

cat >&2 <<'MSG'

  nix/flake.lock on origin/main differs from the one here, and this branch
  does not contain origin/main yet. Applying now would install package
  versions that no longer match the other machines.

      git pull --ff-only && make nix-apply

  If you meant to apply the older lock anyway:

      SKIP_LOCK_DRIFT_CHECK=1 make nix-apply

MSG
exit 1
