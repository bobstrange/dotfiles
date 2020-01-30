# $HOME/bin
export PATH="$HOME/bin:$PATH"

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# nodenv
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"

# pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# go-lang
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# direnv
eval "$(direnv hook zsh)"

# tfenv
export PATH="$HOME/.tfenv/bin:$PATH"

# github token
test -s ~/.github_token &&  source ~/.github_token

## Elixir
# nss ( for mkcert )
export PATH="/usr/local/opt/nss/bin:$PATH"

# asdf
if [[ $(type brew > /dev/null) ]]; then
  test -s "$(brew --prefix asdf)" && source "$(brew --prefix asdf)/asdf.sh"
fi

# Rust
export PATH="$HOME/.cargo/bin:$PATH"
