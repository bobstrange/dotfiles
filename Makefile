.PHONY: run run-ubuntu nix-install nix-switch nix-update

run-ubuntu:
	ansible-playbook ansible/main.yml \
		-i ansible/hosts.ini \
		-l local_ubuntu \
		--ask-become-pass \
		-vvv

# Nix targets
nix-install:
	./setup/nix-setup.sh

nix-switch:
	home-manager switch --flake ./nix#bob@ubuntu

nix-update:
	cd nix && nix flake update && home-manager switch --flake .#bob@ubuntu
