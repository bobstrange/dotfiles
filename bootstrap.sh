#!/bin/bash

usage() {
  echo "Usage: $0 [ubuntu|osx|wsl]"
}

install_homebrew() {
  if ! ls /opt/homebrew/bin/brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

install_python() {
  if [[ $1 = 'osx' ]]; then
    install_homebrew
    eval $(/opt/homebrew/bin/brew shellenv)
    brew update
    brew install openssl readline sqlite3 xz zlib
    brew install python
    pip3 install --upgrade pip
  fi
}

install_ansible() {
  install_python $1

  if ! [[ $1 = 'osx' ]]; then
    if ! type pip3; then
      echo "Installing pip"
      curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
      python3 get-pip.py --user
      rm get-pip.py
    fi

    if ! type ansible; then
      echo "Installing ansible"
      pip3 install --user ansible
    fi
  fi

  if [[ $1 = 'osx' ]]; then
    brew install ansible
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
install_ansible $1
run_playbook $1
