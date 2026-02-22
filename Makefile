.PHONY: help setup-nix setup-macos nix-apply nix-update macos-apply macos-defaults lefthook-setup mise-install symlinks

.DEFAULT_GOAL := help

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Initial setup (run once):"
	@echo "  setup-nix        Install Nix + home-manager + packages (requires shell restart after Nix install)"
	@echo "  setup-macos      Install Homebrew packages + apply macOS defaults + mise runtimes"
	@echo ""
	@echo "Package changes (after editing config):"
	@echo "  nix-apply        Apply nix/*.nix changes"
	@echo "  nix-update       Update all Nix packages to latest versions"
	@echo "  macos-apply      Apply Brewfile changes"
	@echo ""
	@echo "Tools and config (cross-platform):"
	@echo "  lefthook-setup   Generate lefthook.yml and install hooks"
	@echo "  mise-install     Install language runtimes via mise"
	@echo "  symlinks         Symlink secret files from Dropbox"
	@echo ""
	@echo "macOS config:"
	@echo "  macos-defaults   Apply macOS system defaults"

# --- Initial setup ---

setup-nix:
	./setup/nix-setup.sh
	@echo ""
	@echo "Restart your shell, then run: make nix-apply"

setup-macos: macos-apply macos-defaults mise-install

# --- Package changes ---

nix-apply:
	time home-manager switch --flake ./nix#bob@ubuntu
	@if git diff --quiet nix/flake.lock 2>/dev/null; then \
		echo "flake.lock: no changes"; \
	else \
		git add nix/flake.lock && git commit -m "chore: update flake.lock" && \
		echo "flake.lock: committed"; \
	fi

nix-update:
	time sh -c 'cd nix && nix flake update && home-manager switch --flake .#bob@ubuntu'
	@if git diff --quiet nix/flake.lock 2>/dev/null; then \
		echo "flake.lock: no changes"; \
	else \
		git add nix/flake.lock && git commit -m "chore: update flake.lock" && \
		echo "flake.lock: committed"; \
	fi

macos-apply:
	time brew bundle --file=./Brewfile --verbose

# --- Tools and config ---

lefthook-setup:
	bash ./setup/lefthook-gen.sh
	lefthook install

mise-install:
	time mise install

symlinks:
	bash ./setup/symlinks.sh

# --- macOS config ---

macos-defaults:
	bash ./setup/macos/defaults.sh
