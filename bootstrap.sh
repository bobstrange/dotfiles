#!/bin/bash

usage() {
  echo "Usage: $0 [ubuntu|osx|wsl]"
}

install_ansible() {
  if ! type pip; then
    echo "Installing pip"
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python get-pip.py --user
    rm get-pip.py
  fi

  if ! type ansible; then
    echo "Installing ansible"
    pip install --user ansible
  fi
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
    ansible-playbook -i ansible/hosts.ini -l local_ubuntu ansible/main.yml --ask-become-pass -vvv
  fi

  if [[ $1 = 'osx' ]]; then
    ansible-playbook -i ansible/hosts.ini -l local_osx ansible/main.yml --ask-become-pass -vvv
  fi

  if [[ $1 = 'wsl' ]]; then
    ansible-playbook -i ansible/hosts.ini -l local_wsl ansible/main.yml --ask-become-pass -vvv
  fi
}

check_arg $#
install_ansible
run_playbook $1
