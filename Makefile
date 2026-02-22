.PHONY: help setup-nix setup-linux setup-macos \
        nix-apply nix-update macos-apply \
        lefthook-setup xremap-setup mise-install symlinks \
        macos-defaults

.DEFAULT_GOAL := help

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Initial setup (run once):"
	@echo "  setup-nix        Install Nix package manager"
	@echo "  setup-linux      Set up Linux development environment"
	@echo "  setup-macos      Set up macOS development environment"
	@echo ""
	@echo "Apply config changes:"
	@echo "  nix-apply        Apply Nix package config changes"
	@echo "  macos-apply      Apply Homebrew package config changes"
	@echo ""
	@echo "Update packages:"
	@echo "  nix-update       Update Nix packages to latest"
	@echo ""
	@echo "Tools:"
	@echo "  lefthook-setup   Set up git hooks"
	@echo "  xremap-setup     Set up key remapper (Linux/GNOME)"
	@echo "  mise-install     Install language runtimes"
	@echo "  symlinks         Link secret files from Dropbox"
	@echo "  macos-defaults   Apply macOS system preferences"

# --- Initial setup (run once) ---

setup-nix:
	./setup/nix-setup.sh
	@echo ""
	@echo "Restart your shell, then run: make setup-linux"

setup-linux: nix-apply lefthook-setup xremap-setup mise-install
	@echo ""
	@echo "--- Next steps ---"
	@echo "- If added to input group: log out and back in for xremap to work"
	@echo "- After setting up Dropbox: make symlinks"

setup-macos: macos-apply macos-defaults mise-install

# --- Apply config changes ---

nix-apply:
	time home-manager switch --flake ./nix#bob@ubuntu
	@if git diff --quiet nix/flake.lock 2>/dev/null; then \
		echo "flake.lock: no changes"; \
	else \
		git add nix/flake.lock && git commit -m "chore: update flake.lock" && \
		echo "flake.lock: committed"; \
	fi

macos-apply:
	time brew bundle --file=./Brewfile --verbose

# --- Update packages ---

nix-update:
	time sh -c 'cd nix && nix flake update && home-manager switch --flake .#bob@ubuntu'
	@if git diff --quiet nix/flake.lock 2>/dev/null; then \
		echo "flake.lock: no changes"; \
	else \
		git add nix/flake.lock && git commit -m "chore: update flake.lock" && \
		echo "flake.lock: committed"; \
	fi

# --- Tools ---

lefthook-setup:
	bash ./setup/lefthook-gen.sh
	lefthook install

xremap-setup:
	bash ./setup/setup-xremap.sh

mise-install:
	time mise install

symlinks:
	bash ./setup/symlinks.sh

macos-defaults:
	bash ./setup/macos/defaults.sh
