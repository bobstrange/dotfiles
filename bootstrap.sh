#!/bin/bash

# Change dir name to English
LANG=C xdg-user-dirs-gtk-update

# Upgrade dependencies
echo "Updating dependencies"
sudo apt-get update 1>/dev/null
sudo apt-get upgrade -y 1>/dev/null

# Install essential softwares
echo "Installing essential softwares"
sudo apt-get install -y \
curl gcc direnv jq tig tmux git silversearcher-ag xclip rxvt-unicode-256color 1>/dev/null

# Install fzf

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

## redis
sudo apt-get install redis-server
sudo systemctl enable redis-server

## These are needed to build ruby
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt-get update 1> /dev/null
sudo apt-get install -y \
gcc-6 autoconf bison build-essential libssl-dev libyaml-dev \
libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 \
libgdbm-dev 1> /dev/null

echo "Done."

## gnome keychain
sudo apt-get install libgnome-keyring-dev -y 1> /dev/null
sudo make --directory=/usr/share/doc/git/contrib/credential/gnome-keyring 1>/dev/null

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

# Install mysql
sudo apt-get install mysql-server libmysqlclient-dev
mysql_secure_installation

# Install postgres
sudo apt-get install postgresql postgresql-contrib libpq-dev

# Install franz
# Franz brakes windows system when it's crashed on my environment
# So I'll comment out
# wget -P /tmp https://github.com/meetfranz/franz/releases/download/v5.0.0-beta.14/franz_5.0.0-beta.14_amd64.deb
# sudo dpkg -i /tmp/franz_5.0.0-beta.14_amd64.deb
# sudo apt-get install -f -y
# sudo apt-get update

# Install ibus-mozc
sudo apt-get install ibus-mozc -y
echo "You need to do configure some manually."
echo "see: https://mlny.info/2016/05/ibus-skk-on-ubuntu-xenial/"

# Install xremap
sudo apt-get install libx11-dev -y
git clone https://github.com/k0kubun/xremap /tmp/xremap
cd /tmp/xremap
make
sudo make install
mkdir -p ~/.config/systemd/user/
cp -p ~/dotfiles/config/systemd/user/xremap.service ~/.config/systemd/user/xremap.service

# Install apm packages
apm-bundle

# Install gnome extensions
sudo apt install -y chrome-gnome-shell

# install albert
wget -nv https://download.opensuse.org/repositories/home:manuelschneid3r/xUbuntu_16.04/Release.key -O Release.key
sudo apt-key add - < Release.key
sudo apt-get update

echo "Installed albert but make sure you need to configure auto-restart"

# Font

ghq get https://github.com/edihbrandon/RictyDiminished
cp -pr ~/src/github.com/edihbrandon/RictyDiminished /usr/local/share/fonts/
fc-cache -fv

# Ctags
ghq get https://github.com/universal-ctags/ctags
ghq look ctags
./autogen.sh
./configure --prefix=/usr/local
make
sudo make install

# Vim
## Basically followed with https://github.com/Valloric/YouCompleteMe/wiki/Building-Vim-from-source
sudo apt install libncurses5-dev libgnome2-dev libgnomeui-dev \
    libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
    libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev \
    python3-dev ruby-dev lua5.1 lua5.1-dev libperl-dev git

sudo apt remove vim vim-runtime gvim
ghq get https://github.com/vim/vim.git
ghq look vim

## Note:
## Use rbenv installed ruby
## Remove python2.7 since https://stackoverflow.com/questions/23023783/vim-compiled-with-python-support-but-cant-see-sys-version

./configure --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp=dynamic \
            --with-ruby-command=~/.rbenv/shims/ruby \
            --enable-python3interp=yes \
            --with-python3-config-dir=/usr/lib/python3.5/config-3.5m-x86_64-linux-gnu \
            --enable-perlinterp=yes \
            --enable-luainterp=yes \
            --enable-gui=gtk2 \
            --enable-cscope \
            --prefix=/usr/local
make VIMRUNTIMEDIR=/usr/local/share/vim/vim80
sudo apt install checkinstall
sudo checkinstall

## Make vim as default editor
sudo update-alternatives --install /usr/bin/editor editor $(which vim) 1
sudo update-alternatives --set editor $(which vim)
sudo update-alternatives --install /usr/bin/vi vi $(which vim) 1

# install neovim
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt-get update
sudo apt-get install neovim
sudo update-alternatives --set vi $(which nvim)
sudo apt-get install python-dev python-pip python3-dev python3-pip
sudo pip2 install --upgrade neovim
sudo pip3 install --upgrade neovim

