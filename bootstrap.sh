#!/bin/bash

# Upgrade dependencies
echo "Updating dependencies"
sudo apt-get update 1>/dev/null
sudo apt-get upgrade -y 1>/dev/null

# Install essential softwares
echo "Installing essential softwares"
sudo apt-get install -y \
curl gcc direnv jq vim tig tmux git 1>/dev/null

## These are needed to build ruby
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt-get update 1> /dev/null
sudo apt-get install -y \
gcc-6 autoconf bison build-essential libssl-dev libyaml-dev \
libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 \
libgdbm-dev 1> /dev/null

echo "Done."

# Install zsh
echo "Starting to install zsh"
sudo apt-get install -y zsh 1>/dev/null
echo "Change your login shell to zsh"
chsh -s $(which zsh)
echo "Finished to install zsh"

# Install rcm
echo "Starting to install rcm"
wget -qO - https://apt.thoughtbot.com/thoughtbot.gpg.key | sudo apt-key add -
echo "deb http://apt.thoughtbot.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/thoughtbot.list 1>/dev/null
sudo apt-get update 1>/dev/null
sudo apt-get install -y rcm 1>/dev/null
echo "Finished to install rcm"

# Install zplug
echo "Starting to install zplug"
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh

echo "Finished to install zplug"

# Install dropbox
echo "Starting to install dropbox"
cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
echo "Finished to install dropbox"

# Install xxxenv
echo "Starting to install rbenv"
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo "Starting to install ruby-build"
mkdir -p ~/.rbenv/plugins
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
echo "Finished to install rbenv and ruby-build"

echo "Starting to install ndenv"
git clone https://github.com/riywo/ndenv ~/.ndenv
echo "Starting to install node-build"
git clone https://github.com/riywo/node-build.git ~/.ndenv/plugins/node-build
echo "Finished to install ndenv"

# Install atom
echo "Starting to install atom"
curl -L https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add - 
sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
sudo apt-get update 1>/dev/null
sudo apt-get install atom 1>/dev/null
echo "Finished install atom"

# Setup rc files
echo "Setup rc files"
env RCRC=$HOME/dotfiles/rcrc rcup
echo "Done."

# Install go for ghq installation
sudo apt-get install golang-go

# Install ghq
go get github.com/motemen/ghq
