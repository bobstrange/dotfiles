.PHONY: help setup-nix setup-linux setup-wsl setup-macos local-config \
        nix-apply macos-apply update verify bootstrap-test \
        lefthook-setup xremap-setup gnome-extensions-setup ulauncher-setup vscode-setup podman-setup gnome-defaults mise-install symlinks \
        macos-defaults

.DEFAULT_GOAL := help

# Recipes use `time`, which is a bash keyword. Under make's default /bin/sh
# (dash on Ubuntu) it would need /usr/bin/time, which a fresh install lacks.
SHELL := bash

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Initial setup (run once):"
	@echo "  setup-nix                Install Nix package manager"
	@echo "  setup-linux              Set up Linux development environment"
	@echo "  setup-wsl                Set up WSL development environment (no GNOME/xremap)"
	@echo "  setup-macos              Set up macOS development environment"
	@echo "  local-config             Configure machine-local chezmoi settings (work/personal)"
	@echo ""
	@echo "Apply config changes:"
	@echo "  nix-apply                Apply Nix package config changes"
	@echo "  macos-apply              Apply Homebrew package config changes"
	@echo ""
	@echo "Maintenance:"
	@echo "  update                   Update plugins, gh extensions and runtimes"
	@echo "  verify                   Report drift between this repo and this machine"
	@echo "  bootstrap-test           Run setup/bootstrap.sh in a fresh Ubuntu container (needs podman-setup)"
	@echo ""
	@echo "Tools:"
	@echo "  lefthook-setup           Set up git hooks"
	@echo "  xremap-setup             Set up key remapper (Linux/GNOME)"
	@echo "  gnome-extensions-setup   Install GNOME Shell extensions"
	@echo "  ulauncher-setup          Install Ulauncher v6 launcher"
	@echo "  vscode-setup             Install VS Code from Microsoft's apt repository"
	@echo "  podman-setup             Install rootless podman from apt (for bootstrap-test)"
	@echo "  gnome-defaults           Apply GNOME system preferences"
	@echo "  mise-install             Install language runtimes"
	@echo "  symlinks                 Link secret files from Dropbox"
	@echo "  macos-defaults           Apply macOS system preferences"

# --- Initial setup (run once) ---

setup-nix:
	./setup/nix-setup.sh
	@echo ""
	@echo "Restart your shell, then run: make setup-linux"

# mise-install before lefthook-setup: node comes from mise, not nix, and
# lefthook-setup's `npm ci` needs it.
# gnome-extensions-setup before xremap-setup: xremap needs its GNOME extension installed first
setup-linux: nix-apply mise-install lefthook-setup gnome-extensions-setup ulauncher-setup vscode-setup gnome-defaults xremap-setup
	@echo ""
	@echo "--- Next steps ---"
	@echo "- If added to input group: log out and back in for xremap to work"
	@echo "- After setting up Dropbox: make symlinks"

setup-wsl: nix-apply mise-install lefthook-setup
	@echo ""
	@echo "--- Next steps ---"
	@echo "- After setting up Dropbox: make symlinks"

setup-macos: macos-apply macos-defaults mise-install

local-config:
	bash ./setup/setup-local-config.sh

# --- Apply config changes ---

nix-apply:
	@./setup/check-lock-drift.sh
	@if command -v home-manager >/dev/null 2>&1; then \
		time home-manager switch --flake ./nix#bob@ubuntu; \
	else \
		echo "home-manager not found, bootstrapping via nix run..."; \
		time nix run home-manager/master -- switch --flake ./nix#bob@ubuntu; \
	fi
	@if git diff --quiet nix/flake.lock 2>/dev/null; then \
		echo "flake.lock: no changes"; \
	else \
		echo ""; \
		echo "  warning: applying changed nix/flake.lock, which CI owns."; \
		echo "  Adding an input to nix/flake.nix does this; otherwise something"; \
		echo "  is off. It has been left uncommitted — commit it with whatever"; \
		echo "  made it move, or 'git checkout nix/flake.lock' to drop it."; \
		echo ""; \
	fi

macos-apply:
	time brew bundle --file=./Brewfile --verbose

# --- Maintenance ---

update:
	bash ./setup/update.sh

verify:
	bash ./setup/verify.sh

# Extra flags go to the script: make bootstrap-test ARGS=--keep
bootstrap-test:
	bash ./setup/test-bootstrap.sh $(ARGS)

# --- Tools ---

# `mise exec`: from a non-interactive shell (bootstrap.sh) mise's node is not on
# PATH yet, since only .zshrc activates it. lefthook itself is nix's.
lefthook-setup:
	mise exec -- npm ci
	lefthook install

xremap-setup:
	bash ./setup/setup-xremap.sh

gnome-extensions-setup:
	bash ./setup/gnome-extensions.sh

mise-install:
	time mise install

symlinks:
	bash ./setup/symlinks.sh

ulauncher-setup:
	bash ./setup/setup-ulauncher.sh

vscode-setup:
	bash ./setup/setup-vscode.sh

podman-setup:
	bash ./setup/setup-podman.sh

gnome-defaults:
	bash ./setup/gnome-defaults.sh

macos-defaults:
	bash ./setup/macos/defaults.sh
