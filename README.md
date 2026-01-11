# dotfiles

## Requirements

- Dropbox has been installed.
- Dropbox folder should be `~/Dropbox/`.

## Tools

- **[chezmoi](https://www.chezmoi.io/)**: Dotfile management
- **[Nix Flakes](https://nixos.wiki/wiki/Flakes) + [home-manager](https://github.com/nix-community/home-manager)**: Package management (Ubuntu/WSL)
- **[Ansible](https://www.ansible.com/)**: Legacy package management (macOS)

## Usage

### Ubuntu/WSL (Nix)

```bash
# Clone repo
git clone https://github.com/bob1983/dotfiles ~/dotfiles
cd ~/dotfiles

# 1. Install Nix
make nix-install

# 2. Restart shell
exec $SHELL

# 3. Install packages
make nix-bootstrap

# 4. Apply dotfiles
chezmoi apply
```

#### Daily Operations

```bash
# After editing nix/*.nix files
make nix-apply

# Update all packages to latest
make nix-update

# Search for packages
nix search nixpkgs <package-name>

# Rollback to previous generation
home-manager rollback
```

### macOS (Ansible - Legacy)

```bash
# Clone repo
git clone https://github.com/bob1983/dotfiles ~/dotfiles
cd ~/dotfiles

# Run setup script
./setup/setup.sh osx
```

Or run Ansible manually:

```bash
cd setup/ansible

ansible-playbook \
  -i inventory/hosts.yml \
  playbooks/setup.yml \
  --limit osx \
  --ask-become \
  -v
```

## Help

```bash
make help
```

## Note

### Ulauncher

I configured hotkey to Alt + Space as Ctrl + Space is used for intellisense

