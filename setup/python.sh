PYTHON_2_VERSION="2.7.14"
PYTHON_3_VERSION="3.6.4"

install_python2() {
  pyenv install ${PYTHON_2_VERSION}
  pyenv global ${PYTHON_2_VERSION}
  pyenv rehash
  pip2 intall neovim
}

install_python3() {
  pyenv install ${PYTHON_3_VERSION}
  pyenv global ${PYTHON_3_VERSION}
  pyenv rehash
  pip3 intall neovim
}

install_python() {
  install_python2
  install_python3
}

