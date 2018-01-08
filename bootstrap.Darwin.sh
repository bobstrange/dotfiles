#!/bin/bash

setup_dotfile() {
  brew tap "thoughtbot/formulae"
  brew install rcm
  env RCRC=$HOME/dotfiles/rcrc rcup
}

install_dependencies() {
  brew install git gcc direnv tig ghq tmux wget zplug terraform jq peco neovim
  brew install coreutils findutils gnu-tar gnu-sed gawk gnutls gnu-indent gnu-getopt
  brew tap homebrew/dupes; brew install grep
}

install_zsh() {
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh
  chsh -s /bin/zsh
}

change_host() {
  sudo scutil --set ComputerName bob-mbp
  sudo scutil --set LocalHostName bob-mbp
}

install_casks() {
  brew cask install alfred google-chrome google-japanese-ime skype iterm2 karabiner shiftit macs-fan-control dropbox
}

if [ $(uname) == 'Darwin' ]; then
  . setup/install_homebrew.sh
  setup_dotfile
  install_dependencies
  install_casks
  install_zsh
  change_host
else
  echo "This script doesn't support $(uname)"
  exit 1
fi
