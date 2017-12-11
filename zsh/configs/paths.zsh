# openssl
export PATH="/usr/local/opt/openssl/bin:$PATH"

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# ndenv
export PATH=$HOME/.ndenv/bin:$PATH
eval "$(ndenv init -)"

# pyenv
eval "$(pyenv init -)"

# direnv
eval "$(direnv hook zsh)"

# go
export GOROOT=/usr/local/Cellar/go
export GOPATH="$HOME/.go"
export PATH="$GOPATH:$PATH"

# yarn
export PATH="$PATH:`yarn global bin`"

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

# hub
eval "$(hub alias -s)"
