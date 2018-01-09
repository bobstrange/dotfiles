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

install_font() {
  brew tap sanemat/font
  brew reinstall ricty --with-powerline --with-patch-in-place
  cp -f /usr/local/opt/ricty/share/fonts/Ricty*.ttf ~/Library/Fonts/
  fc-cache -vf
}

change_host() {
  sudo scutil --set ComputerName bob-mbp
  sudo scutil --set LocalHostName bob-mbp
}

install_casks() {
  brew cask install alfred google-chrome google-japanese-ime skype iterm2 karabiner shiftit macs-fan-control dropbox coteditor
}

install_xxenv() {
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  mkdir -p ~/.rbenv/plugins
  eval "$(rbenv init -)"

  git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

  git clone https://github.com/riywo/ndenv ~/.ndenv
  eval "$(ndenv init -)"
  git clone https://github.com/riywo/node-build.git ~/.ndenv/plugins/node-build
}

setup_ruby() {
  for version in 2.3.1 2.3.3 2.5.0; do
    rbenv install ${version}
    rbenv global ${version}
    gem install bundler
  done
  rbenv global 2.5.0
}

setup_node() {
  for version in 8.9.4 6.9.2; do
    ndenv install ${version}
  done
  ndenv global 8.9.4
  brew install yarn --without-node
}

install_atom() {
  brew cask install atom
  apm install --packages-file ~/dotfiles/atom/installed_packages
}

install_mysql() {
  brew install mysql
  brew services start mysql
}

install_postgresql() {
  brew install postgresql@9.6
  brew services start postgresql@9.6
}

install_redis() {
  brew install redis
  brew services start redis
}

if [ $(uname) == 'Darwin' ]; then
  . setup/install_homebrew.sh
  setup_dotfile
  install_dependencies
  install_casks
  install_zsh
  install_font
  change_host
  install_xxenv
  install_atom
  install_mysql
  install_redis
else
  echo "This script doesn't support $(uname)"
  exit 1
fi
