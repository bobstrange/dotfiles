#!/bin/bash

if [ $(uname) == 'Darwin' ]; then
  if type brew >& /dev/null; then
    echo "Homebrew has already installed"
  else
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
else
  echo "You cannnot install homebrew except osx environment"
  exit 1
fi

