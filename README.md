# dotfiles

## Requirements

- Dropbox has been installed.
- Dropbox folder should be `~/Dropbox/`.

## Tools

- [Ansible](https://www.ansible.com/)
- [chezmoi](https://www.chezmoi.io/)

## Usage

### bootstrap

```bash
# Checkout repo
git clone https://github.com/bob1983/dotfiles ~/dotfiles
cd dotfiles

# Run setup script
# ubuntu
./setup/setup.sh ubuntu
# osx
./setup/setup.sh osx
# wsl
./setup/setup.sh wsl
```

### run ansible playbook

```bash
cd setup/ansible

ansible-playbook \
  -i inventory/hosts.yml \
  playbooks/setup.yml \
  --limit osx
  --ask-become \
  -v
```

`--limit osx` could be `--limit osx`, `--limit ubuntu` or `--limit wsl`.

## Note

### Ulauncher

I configured hotkey to Alt + Space as Ctrl + Space is used for intellisense

