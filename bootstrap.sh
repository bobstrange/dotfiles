#!/bin/bash

usage() {
  echo "Usage: $0 [ubuntu|osx|wsl]"
}

if [ $# -ne 1 ]; then
  echo $(usage)
  exit 1
fi

if [ $1 = 'ubuntu' ]; then
  ansible-playbook -i ansible/hosts.ini -l local_ubuntu ansible/main.yml --ask-become-pass -vvv --check
fi

if [ $1 = 'osx' ]; then
  ansible-playbook -i ansible/hosts.ini -l local_osx ansible/main.yml --ask-become-pass -vvv
fi

if [ $1 = 'wsl' ]; then
  ansible-playbook -i ansible/hosts.ini -l local_wsl ansible/main.yml --ask-become-pass -vvv
fi
