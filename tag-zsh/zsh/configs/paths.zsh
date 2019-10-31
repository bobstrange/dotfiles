# openssl
export PATH="/usr/local/opt/openssl/bin:$PATH"

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# ndenv
export PATH=$HOME/.ndenv/bin:$PATH
eval "$(ndenv init -)"

# pyenv
export PATH=$HOME/.pyenv/bin:$PATH
export PYENV_ROOT=$HOME/.pyenv
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# go
export GOPATH="$HOME/.go"
export PATH="$GOPATH/bin:$PATH"

# direnv
eval "$(direnv hook zsh)"

# tfenv
export PATH="$HOME/.tfenv/bin:$PATH"

# github token
if ls ~/.github_token; then
  source ~/.github_token
fi

## Elixir
# kerl
export KERL_BASE_DIR=$HOME/.kerl
export KERL_DEFAULT_INSTALL_DIR=$KERL_BASE_DIR/installs
export KERL_BUILD_BACKEND=git

# kiex
test -s "$HOME/.kiex/scripts/kiex" && source "$HOME/.kiex/scripts/kiex"

# nss ( for mkcert )
export PATH="/usr/local/opt/nss/bin:$PATH"

# asdf
test -s "$HOME/.asdf/" && source "$HOME/.asdf/asdf.sh"
test -s "$HOME/.asdf/" && source "$HOME/.asdf/completions/asdf.bash"
