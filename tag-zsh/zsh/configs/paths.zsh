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
# nss ( for mkcert )
export PATH="/usr/local/opt/nss/bin:$PATH"

# asdf
test -s "$(brew --prefix asdf)" && source "$(brew --prefix asdf)/asdf.sh"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"
