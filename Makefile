.PHONY: help nix-install nix-bootstrap nix-apply nix-update macos-install macos-defaults macos-setup symlinks

.DEFAULT_GOAL := help

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Common:"
	@echo "  symlinks       Symlink secret files from Dropbox (~/.ssh, ~/.aws, tokens)"
	@echo ""
	@echo "macOS:"
	@echo "  macos-install  Install Homebrew packages (brew bundle)"
	@echo "  macos-defaults Apply macOS system defaults"
	@echo "  macos-setup    Run both (initial setup)"
	@echo ""
	@echo "Nix (initial setup - run in order):"
	@echo "  nix-install    1. Install Nix package manager (requires shell restart)"
	@echo "  nix-bootstrap  2. Install home-manager and packages"
	@echo ""
	@echo "Nix (daily use):"
	@echo "  nix-apply      Apply nix/*.nix changes (install/remove packages)"
	@echo "  nix-update     Update all packages to latest versions"

# Common: Symlink secret files from Dropbox
symlinks:
	bash ./setup/symlinks.sh

# macOS: Install Homebrew packages
macos-install:
	time brew bundle --file=./Brewfile --verbose

# macOS: Apply system defaults
macos-defaults:
	bash ./setup/macos/defaults.sh

# macOS: Full initial setup
macos-setup: macos-install macos-defaults

# Nix: Install Nix package manager
# Run once on fresh system, then restart shell
nix-install:
	./setup/nix-setup.sh

# Nix: Bootstrap home-manager and install packages
# Run once after nix-install
nix-bootstrap:
	time nix run nixpkgs#home-manager -- switch --flake ./nix#bob@ubuntu

# Nix: Apply configuration changes
# Run after editing nix/*.nix files to install/remove packages
nix-apply:
	time home-manager switch --flake ./nix#bob@ubuntu
	@if git diff --quiet nix/flake.lock 2>/dev/null; then \
		echo "flake.lock: no changes"; \
	else \
		git add nix/flake.lock && git commit -m "chore: update flake.lock" && \
		echo "flake.lock: committed"; \
	fi

# Nix: Update all packages to latest versions
# Updates flake.lock and applies changes
nix-update:
	time sh -c 'cd nix && nix flake update && home-manager switch --flake .#bob@ubuntu'
	@if git diff --quiet nix/flake.lock 2>/dev/null; then \
		echo "flake.lock: no changes"; \
	else \
		git add nix/flake.lock && git commit -m "chore: update flake.lock" && \
		echo "flake.lock: committed"; \
	fi
