#!/bin/bash

function change_default_directory_name_from_japanease_to_engilish() {
  LANG=C xdg-user-dirs-gtk-update
}

function cleanup() {
  sudo apt autoremove
}

function update() {
  sudo apt-get update
  sudo apt-get upgrade -y
}

function install_essential() {
  sudo apt-get install -y \
  curl gcc direnv jq tig tmux git silversearcher-ag xclip rxvt-unicode-256color
}

function install_zsh() {
  sudo apt-get install -y zsh
  chsh -s $(which zsh)
}

function setup_dotfile() {
  wget -qO - https://apt.thoughtbot.com/thoughtbot.gpg.key | sudo apt-key add -
  echo "deb http://apt.thoughtbot.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/thoughtbot.list 1>/dev/null
  sudo apt-get update
  sudo apt-get install -y rcm
  env RCRC=$HOME/dotfiles/rcrc rcup
}

function install_dropbox() {
  cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
  ~/.dropbox-dist/dropboxd&
}

function install_fzf() {
  if [[ ! -d ~/.fzf/ ]];then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  fi
  ~/.fzf/install
}

function install_zplug() {
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh
}

function install_redis() {
  sudo apt-get install redis-server -y
  sudo systemctl enable redis-server
}

function install_gnome_keychain() {
  sudo apt-get install libgnome-keyring-dev -y
  sudo make --directory=/usr/share/doc/git/contrib/credential/gnome-keyring
}

function install_dependencies_for_ruby() {
  sudo add-apt-repository ppa:ubuntu-toolchain-r/test
  sudo apt-get update
  sudo apt-get install -y \
  gcc-6 autoconf bison build-essential libssl-dev libyaml-dev \
  libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 \
  libgdbm-dev
}

function setup_ruby_dev_env() {
  install_dependencies_for_ruby
  if [[ ! -d ~/.rbenv ]]; then
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  fi
  mkdir -p ~/.rbenv/plugins
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
}

function setup_ndenv() {
  if [[ ! -d ~/.ndenv ]]; then
    git clone https://github.com/riywo/ndenv ~/.ndenv
  fi
  mkdir -p ~/.ndenv/plugins
  git clone https://github.com/riywo/node-build.git ~/.ndenv/plugins/node-build
}

function install_vim() {
  ## Basically followed with https://github.com/Valloric/YouCompleteMe/wiki/Building-Vim-from-source
  sudo apt install libncurses5-dev libgnome2-dev libgnomeui-dev \
      libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
      libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev \
      python3-dev ruby-dev lua5.1 lua5.1-dev libperl-dev git

  sudo apt remove vim vim-runtime gvim
  ghq get https://github.com/vim/vim.git
  cd ~/src/github.com/vim/vim

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
  sudo update-alternatives --install /usr/bin/editor editor $(which vim) 20
  sudo update-alternatives --install /usr/bin/vi vi $(which vim) 20
}

function install_neovim() {
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

function install_atom() {
  curl -L https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
  sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
  sudo apt-get update
  sudo apt-get install atom -y
  apm install --packages-file ~/dotfiles/atom/installed_packages
}

function install_go() {
  # version 1.8 will be installed for Ubuntu 17.10
  sudo apt-get install golang-go -y
# Need to restart to update login shell
}

function install_ghq() {
  go get github.com/motemen/ghq
}

function install_hub() {
  # Install hub
  ghq get https://github.com/github/hub.git
  cd ~/src/github.com/github/hub
  # Install bundler to system ruby
  sudo gem install bundler
  sudo make install prefix=/usr/local
}

function setup_mysql() {
  sudo apt-get install mysql-server libmysqlclient-dev -y
  mysql_secure_installation
}

function setup_postgres() {
  sudo apt-get install postgresql postgresql-contrib libpq-dev -y
}

function install_ibus_mozc() {
  # Need to configure some manually
  # see:  https://mlny.info/2016/05/ibus-skk-on-ubuntu-xenial/
  sudo apt-get install ibus-mozc -y
}

function install_xremap() {
  sudo apt-get install libx11-dev -y
  git clone https://github.com/k0kubun/xremap /tmp/xremap
  cd /tmp/xremap
  make
  sudo make install

  mkdir -p ~/.config/systemd/user/
  cp -p ~/dotfiles/config/systemd/user/xremap.service ~/.config/systemd/user/xremap.service
  systemctl --user enable xremap
  systemctl --user start xremap
}

function gnome_extensions() {
  sudo apt install -y chrome-gnome-shell
}

function function install_albert() {
  sudo sh -c "echo 'deb http://download.opensuse.org/repositories/home:/manuelschneid3r/xUbuntu_17.10/ /' > /etc/apt/sources.list.d/albert.list"
  sudo apt-get update
  sudo apt-get install albert -y
}

function install_font() {
  ghq get https://github.com/edihbrandon/RictyDiminished
  sudo cp -pr ~/src/github.com/edihbrandon/RictyDiminished /usr/local/share/fonts/
  fc-cache -fv
}

function install_ctags() {
  ghq get https://github.com/universal-ctags/ctags
  cd ~/src/github.com/universal-ctags/ctags
  ./autogen.sh
  ./configure --prefix=/usr/local
  make
  sudo make install
}

function install_ssh_server() {

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

function install_pyenv() {
  curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
}

function install_diff_so_fancy() {
  npm install -g diff-so-fancy
}

function install_ansible() {
  sudo apt-get update
  sudo apt-get install software-prperties-common
  sudo apt-add-repository ppa:ansible/ansible
  sudo apt-get update
  sudo apt-get install ansible -y
}

function install_powerline() {
  ghq get powerline/fonts
  cd ~/src/github.com/powerline/fonts
  ./install.sh
}

function install_vagrant() {
  sudo apt-get install virtualbox vagrant -y
}
uname -v | grep -q "Ubuntu"
ubuntu=$?

if [[ ${ubuntu} = 0 ]];then
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
  install_diff_so_fancy
  cleanup
fi
