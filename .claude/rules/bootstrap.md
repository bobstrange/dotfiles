---
paths:
  - "setup/**"
  - "Makefile"
  - ".chezmoiscripts/**"
---

# Bootstrap

`setup/bootstrap.sh` (`curl | bash`) is the whole "rebuild from scratch" story, and
`make bootstrap-test` (`setup/test-bootstrap.sh`) is what makes that claim true: it runs the
script in a fresh `ubuntu:26.04` podman container with systemd as PID 1 and nothing but
`systemd sudo curl` installed, then asserts on the result from inside nix's zsh. Keep the two
in step. The test sets `MISE_DISABLE_TOOLS=erlang,elixir`: erlang is a multi-minute source
build that says nothing about bootstrap itself, and the whole run is otherwise under three
minutes.

The order inside bootstrap is **`chezmoi apply` first, then `make setup-*`**. It used to be
the reverse, which silently did nothing useful: `mise install` reads
`~/.config/mise/config.toml`, so on an unapplied machine it installs nothing and exits 0, and
`lefthook-setup`'s `npm ci` then fails for lack of node. apply needs nothing from nix, so
there is no reason to wait. Likewise `mise-install` precedes `lefthook-setup` in the Makefile,
and `lefthook-setup` runs `mise exec -- npm ci`, because a non-interactive shell has no
`.zshrc` and hence no mise on PATH.
