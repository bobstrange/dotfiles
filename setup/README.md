# Setup

## Setup

Use playbooks/setup.yml to setup your environment with `--limit (osx|linux|wsl)` flag.

```bash
ansible-playbook -i inventory/hosts.yml playbooks/setup.yml --limit osx -v
```
