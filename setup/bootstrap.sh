#!/bin/bash

usage() {
  echo "Usage: $0 [ubuntu|osx|wsl]"
}

install_ansible() {
  if [[ $1 = 'ubuntu' || $1 = 'wsl' ]]; then
    sudo apt update && sudo apt install pipx
    pipx ensurepath
  fi

  if [[ $1 = 'osx' ]]; then
    brew update && brew install pipx
    pipx ensurepath
  fi

  pipx install --include-deps ansible
}

check_arg() {
  if [ $1 -ne 1 ]; then
    echo $(usage)
    exit 1
  fi
}

run_playbook() {
  echo "Arg: $1"
  if [[ $1 = 'ubuntu' ]]; then
    ansible-playbook -i ansible/inventory/hosts.yml -l ubuntu ansible/main.yml --ask-become-pass -vvv
  fi

  if [[ $1 = 'osx' ]]; then
    ansible-playbook -i ansible/inventory/hosts.yml -l osx ansible/main.yml --ask-become-pass -vvv
  fi

  if [[ $1 = 'wsl' ]]; then
    ansible-playbook -i ansible/inventory/hosts.yml -l wsl ansible/main.yml --ask-become-pass -vvv
  fi
}

check_arg $#
install_ansible $1
run_playbook $1
