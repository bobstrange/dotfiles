#!/bin/bash

setup_dotfile() {
  brew tap "thoughtbot/formulae"
  brew install rcm
  env RCRC=$HOME/dotfiles/rcrc rcup
}

show_hidden_files() {
  defaults write com.apple.finder AppleShowAllFiles TRUE
  killall Finder
}

install_dependencies() {
  # For neovim https://github.com/pyenv/pyenv/wiki/Common-build-problems
  brew install readline xz

  brew install git gcc direnv tig ghq tmux wget zplug terraform jq peco neovim packer
  brew install coreutils findutils gnu-tar gnu-sed gawk gnutls gnu-indent gnu-getopt
  brew tap homebrew/dupes; brew install grep
  brew install diff-so-fancy
}

install_zsh() {
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh
  chsh -s /bin/zsh
  exec $SHELL -s
}

install_fzf() {
  brew install fzf
  $(brew --prefix)/opt/fzf/install
}

install_font() {
  brew tap sanemat/font
  brew reinstall ricty --with-powerline --with-patch-in-place
  cp -f /usr/local/opt/ricty/share/fonts/Ricty*.ttf ~/Library/Fonts/
  fc-cache -vf
}

install_colorscheme() {
  ghq get https://github.com/mbadolato/iTerm2-Color-Schemes
}

change_host() {
  sudo scutil --set ComputerName bob-mbp
  sudo scutil --set LocalHostName bob-mbp
}

install_casks() {
  brew cask install \
    alfred google-chrome google-japanese-ime skype \
    iterm2 karabiner shiftit macs-fan-control dropbox \
    coteditor franz lastpass kindle slack vagrant virtualbox
}


install_rbenv() {
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  mkdir -p ~/.rbenv/plugins
  eval "$(rbenv init -)"
  git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
}

install_pyenv() {
  curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
}

install_ndenv() {
  git clone https://github.com/riywo/ndenv ~/.ndenv
  eval "$(ndenv init -)"
  git clone https://github.com/riywo/node-build.git ~/.ndenv/plugins/node-build
}

install_xxenv() {
  install_rbenv
  install_pyenv
  install_ndenv
}

# They should have beend done on dev_langs.sh
# setup_ruby() {
#   for version in 2.3.1 2.3.3 2.5.0; do
#     rbenv install ${version}
#     rbenv global ${version}
#     gem install bundler
#   done
#   rbenv global 2.5.0
# }
#
# setup_node() {
#   for version in 8.9.4 6.9.2; do
#     ndenv install ${version}
#   done
#   ndenv global 8.9.4
#   brew install yarn --without-node
# }

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

install_ctags() {
  brew install --HEAD universal-ctags/universal-ctags/universal-ctags
}

install_aws_cli() {
  pip3 install aws-cli
}

if [ $(uname) == 'Darwin' ]; then
  . setup/install_homebrew.sh
  setup_dotfile
  show_hidden_files
  install_dependencies
  install_casks
  install_zsh
  install_font
  change_host
  install_xxenv
  install_atom
  install_mysql
  install_redis
  install_ctags
  install_colorschemes
  install_fzf
  install_aws_cli
else
  echo "This script doesn't support $(uname)"
  exit 1
fi
