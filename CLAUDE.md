# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## About This Repository

This is a personal dotfiles repository managed with [chezmoi](https://www.chezmoi.io/) and [Ansible](https://www.ansible.com/). It contains configuration files and setup scripts for macOS, Ubuntu, and WSL environments.

## Key Commands

### Setup and Bootstrap

- Initial setup: `./setup/setup.sh [ubuntu|osx|wsl]` from the dotfiles directory
- Run Ansible playbook: `cd setup/ansible && ansible-playbook -i inventory/hosts.yml playbooks/setup.yml --limit [osx|ubuntu|wsl] --ask-become -v`
- Quick Ubuntu setup: `make run-ubuntu` (runs Ansible with verbose output)

### Chezmoi Management

- Apply changes: `chezmoi apply`
- Check differences: `chezmoi diff`
- Edit files: `chezmoi edit <file>`
- Add new files: `chezmoi add <file>`

## Architecture

### File Structure

- **Root dotfiles**: Files prefixed with `dot_` become `.` files in the home directory
- **Executable files**: Files prefixed with `executable_` become executable
- **Templates**: Files ending with `.tmpl` are processed as templates
- **Platform-specific configs**: Organized in subdirectories like `dot_config/`

### Key Components

- **Ansible roles** in `setup/ansible/roles/` handle software installation and system configuration
- **Shell configuration** split across `dot_zsh/` with modular configs and functions
- **Development tools** configured via individual dotfiles (vim, tmux, git, etc.)
- **Platform detection** in Ansible inventory supports macOS, Ubuntu, and WSL

### Template System

- Uses chezmoi templates for platform-specific configurations
- Variables defined in Ansible host vars (`setup/ansible/inventory/host_vars/`)
- Git config uses templates for conditional email/username settings

## Development Notes

- The repository supports multi-platform development environments
- Ansible playbooks are idempotent and can be run multiple times safely
- Configuration is modular - individual components can be modified without affecting others
- Shell functions and aliases are organized by platform in `dot_zsh/configs/`
