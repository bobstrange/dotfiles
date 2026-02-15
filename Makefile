.PHONY: help run-ubuntu nix-install nix-bootstrap nix-apply nix-update

.DEFAULT_GOAL := help

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Ansible:"
	@echo "  run-ubuntu     Run Ansible playbook for Ubuntu"
	@echo ""
	@echo "Nix (initial setup - run in order):"
	@echo "  nix-install    1. Install Nix package manager (requires shell restart)"
	@echo "  nix-bootstrap  2. Install home-manager and packages"
	@echo ""
	@echo "Nix (daily use):"
	@echo "  nix-apply      Apply nix/*.nix changes (install/remove packages)"
	@echo "  nix-update     Update all packages to latest versions"

# Ansible: Run playbook for Ubuntu
run-ubuntu:
	ansible-playbook ansible/main.yml \
		-i ansible/hosts.ini \
		-l local_ubuntu \
		--ask-become-pass \
		-vvv

# Nix: Install Nix package manager
# Run once on fresh system, then restart shell
nix-install:
	./setup/nix-setup.sh

# Nix: Bootstrap home-manager and install packages
# Run once after nix-install
nix-bootstrap:
	nix run nixpkgs#home-manager -- switch --flake ./nix#bob@ubuntu

# Nix: Apply configuration changes
# Run after editing nix/*.nix files to install/remove packages
nix-apply:
	home-manager switch --flake ./nix#bob@ubuntu
	@if git diff --quiet nix/flake.lock 2>/dev/null; then \
		echo "flake.lock: no changes"; \
	else \
		git add nix/flake.lock && git commit -m "chore: update flake.lock" && \
		echo "flake.lock: committed"; \
	fi

# Nix: Update all packages to latest versions
# Updates flake.lock and applies changes
nix-update:
	cd nix && nix flake update && home-manager switch --flake .#bob@ubuntu
	@if git diff --quiet nix/flake.lock 2>/dev/null; then \
		echo "flake.lock: no changes"; \
	else \
		git add nix/flake.lock && git commit -m "chore: update flake.lock" && \
		echo "flake.lock: committed"; \
	fi
