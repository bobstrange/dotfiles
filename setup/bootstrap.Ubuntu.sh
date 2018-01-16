#!/bin/bash
set -eu

change_default_directory_name_from_japanease_to_engilish() {
  LANG=C xdg-user-dirs-gtk-update
}

update() {
  sudo apt-get update
  sudo apt-get upgrade -y
}

install_essential() {
  sudo apt-get install -y
  curl gcc direnv jq tig tmux git silversearcher-ag xclip rxvt-unicode-256color
}

install_zsh() {
  sudo apt-get install -y zsh
  chsh -s $(which zsh)
}

setup_dotfile() {
  wget -qO - https://apt.thoughtbot.com/thoughtbot.gpg.key | sudo apt-key add -
  echo "deb http://apt.thoughtbot.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/thoughtbot.list 1>/dev/null
  sudo apt-get update
  sudo apt-get install -y rcm
  env RCRC=$HOME/dotfiles/rcrc rcup
}

install_dropbox() {
  cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
  ~/.dropbox-dist/dropboxd
}

install_fzf() {
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
}

install_zplug() {
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh
}

install_redis() {
  sudo apt-get install redis-server -y
  sudo systemctl enable redis-server
}

install_gnome_keychain() {
  sudo apt-get install libgnome-keyring-dev -y
  sudo make --directory=/usr/share/doc/git/contrib/credential/gnome-keyring
}

install_dependencies_for_ruby() {
  sudo add-apt-repository ppa:ubuntu-toolchain-r/test
  sudo apt-get update
  sudo apt-get install -y
  gcc-6 autoconf bison build-essential libssl-dev libyaml-dev \
  libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 \
  libgdbm-dev
}

setup_ruby_dev_env() {
  install_dependencies_for_ruby
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  mkdir -p ~/.rbenv/plugins
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
}

setup_ndenv() {
  git clone https://github.com/riywo/ndenv ~/.ndenv
  mkdir -p ~/.ndenv/plugins
  git clone https://github.com/riywo/node-build.git ~/.ndenv/plugins/node-build
}

install_vim() {
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
  sudo apt install checkinstall -y
  sudo checkinstall

  sudo update-alternatives --install /usr/bin/editor editor $(which vim) 20
  sudo update-alternatives --install /usr/bin/vi vi $(which vim) 20
}

install_neovim() {
  sudo add-apt-repository ppa:neovim-ppa/stable
  sudo apt-get update
  sudo apt-get install neovim

  # Make nvim as default editor
  sudo update-alternatives --set editor $(which nvim)
  sudo update-alternatives --set vi $(which nvim)
  sudo update-alternatives --set vim $(which nvim)

  sudo apt-get install python-dev python-pip python3-dev python3-pip
  sudo pip2 install --upgrade neovim
  sudo pip3 install --upgrade neovim
}

install_atom() {
  curl -L https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
  sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
  sudo apt-get update
  sudo apt-get install atom -y
  apm install --packages-file ~/dotfile/atom/installed_packages
}

install_go() {
  # version 1.8 will be installed for Ubuntu 17.10
  sudo apt-get install golang-go -y
# Need to restart to update login shell
}

install_ghq() {
  go get github.com/motemen/ghq
}

install_hub() {
  # Install hub
  # Need to install ruby
  ghq get https://github.com/github/hub.git
  ghq look hub
  sudo make install prefix=/usr/local
}

setup_mysql() {
  sudo apt-get install mysql-server libmysqlclient-dev -y
  mysql_secure_installation
}

setup_postgres() {
  sudo apt-get install postgresql postgresql-contrib libpq-dev -y
}

install_ibus_mozc() {
  # Need to configure some manually
  # see:  https://mlny.info/2016/05/ibus-skk-on-ubuntu-xenial/
  sudo apt-get install ibus-mozc -y
}

install_xremap() {
  sudo apt-get install libx11-dev -y
  git clone https://github.com/k0kubun/xremap /tmp/xremap
  cd /tmp/xremap
  make
  sudo make install
  # TODO: Need to be fixed
  mkdir -p ~/.config/systemd/user/
  cp -p ~/dotfiles/config/systemd/user/xremap.service ~/.config/systemd/user/xremap.service
}


# Install gnome extensions
install_gnome_extensions() {
  sudo apt install -y chrome-gnome-shell
}

# install albert
install_albert() {
  # Need to configure startup
  cd
  wget -nv https://download.opensuse.org/repositories/home:manuelschneid3r/xUbuntu_16.04/Release.key -O Release.key
  sudo apt-key add - < Release.key
  sudo apt-get update
  sudo apt-get install albert -y
}

# Font
install_font() {
  ghq get https://github.com/edihbrandon/RictyDiminished
  cp -pr ~/src/github.com/edihbrandon/RictyDiminished /usr/local/share/fonts/
  fc-cache -fv
}

# Ctags
install_ctags() {
  ghq get https://github.com/universal-ctags/ctags
  ghq look ctags
  ./autogen.sh
  ./configure --prefix=/usr/local
  make
  sudo make install
}

install_ssh_server() {

  ## Need to change /etc/ssh/sshd_config
  # Port 22 -> xx
  # LoginGraceTime 120 -> 10
  # PermitRootLogin -> no
  # MaxAuthTries -> 3
  # MaxSessions  -> 3
  # AuthorizedKeysFile -> .ssh/authorized_keys
  # PasswordAuthentication -> no


  ## After you update the sshd_config, you need to restart the daemon
  ## sudo systemctl restart sshd

  sudo apt-get install openssh-server -y
}

uname -v | grep -q "Ubuntu"
ubuntu=$?

if [[ ${ubuntu} = 0 ]];then
  change_default_directory_name_from_japanease_to_engilish
  update
  install_essential
  install_zsh
  setup_dotfile
  install_dropbox
  install_fzf
  install_zplug
  install_redis
  install_gnome_keychain
  install_dependencies_for_ruby
  setup_ruby_dev_env
  setup_ndenv
  install_vim
  install_neovim
  install_atom
  install_go
  install_ghq
  install_hub
  setup_mysql
  setup_postgres
  install_ibus_mozc
  install_xremap
  install_gnome_extensions
  install_albert
  install_font
  install_ctags
  install_ssh_server
fi
