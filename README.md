# dotfiles
## Dependencies
- pip
- ansible
- rcm

## Usage
### bootstrap

```shell
# Checkout repo
git clone https://github.com/bob1983/dotfiles ~/dotfiles
cd dotfiles

# Run bootstrap script
# ubuntu
./bootstrap.sh ubuntu
# osx
./bootstrap.sh osx
# wsl
./bootstrap.sh wsl
```

### run ansible playbook

```shell
ansible-playbook ansible/main.yml \
  -i ansible/hosts.ini \
  -l local_ubuntu \
  --ask-become-pass \
  -vvv
```

`-l local_ubuntu` could be `-l local_osx` or `local_wsl`

### deploy rc files

```shell
# lsrc to check which file will be updated
RCRC=~/dotfiles/rcrc lsrc

#  You can specify a certain tag to be updated
RCRC=~/dotfiles/rcrc lsrc -t vim

# rcup to update rc files
RCRC=~/dotfiles/rcrc rcup
RCRC=~/dotfiles/rcrc rcup -t vim
```
