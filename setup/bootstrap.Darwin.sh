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

change_screenshot_filename() {
  defaults write com.apple.screencapture name "ScreenShot"
  # You can switch the screenshot location
  # defaults write com.apple.screencapture location ~/ScreenShot/<Paste>

  # You can remove timestamp
  # defaults write com.apple.screencapture include-date -bool false
  killall SystemUIServer
}

install_dependencies() {
  # For neovim https://github.com/pyenv/pyenv/wiki/Common-build-problems
  brew install readline xz

  brew install git gcc direnv tig ghq tmux wget zplug terraform jq neovim \
    packer tree
  brew install coreutils findutils gnu-tar gnu-sed gawk gnutls gnu-indent gnu-getopt
  brew install grep
  brew install diff-so-fancy
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

install_colorschemes() {
  ghq get https://github.com/mbadolato/iTerm2-Color-Schemes
}

change_host() {
  sudo scutil --set ComputerName bob-mbp
  sudo scutil --set LocalHostName bob-mbp
}

install_casks() {
  brew install --cask \
    alfred \
    google-chrome \
    google-japanese-ime \
    iterm2 \
    # Rust based terminal
    warp \
    shiftit \
    dropbox \
    coteditor \
    kindle \
    slack \
    tg-pro \
    1password
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

install_aws_cli() {
  curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
  sudo installer -pkg AWSCLIV2.pkg -target /
}

if [ $(uname) == 'Darwin' ]; then
  . setup/install_homebrew.sh
  setup_dotfile
  show_hidden_files
  change_screenshot_filename
  install_dependencies
  install_casks
  install_font
  change_host
  install_xxenv
  install_colorschemes
  install_fzf
  install_aws_cli
else
  echo "This script doesn't support $(uname)"
  exit 1
fi
