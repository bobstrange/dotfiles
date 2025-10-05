# Add xdg config home
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"

# $HOME/bin
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
command rbenv 2>/dev/null && eval "$(rbenv init -)"

# nodenv
export PATH="$HOME/.nodenv/bin:$PATH"
command nodenv 2>/dev/null && eval "$(nodenv init -)"

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
command pyenv 2>/dev/null && eval "$(pyenv init -)"
command virtualenv 2>/dev/null && eval "$(pyenv virtualenv-init -)"

# golang
export GOPATH="$HOME/dev"
export PATH="$GOPATH/bin:$PATH"
command go 2>/dev/null && export GOROOT=$(go env GOROOT)
export GO111MODULE=on

# direnv
eval "$(direnv hook zsh)"

# tfenv
export PATH="$HOME/.tfenv/bin:$PATH"

# github token
test -s ~/.github_token && source ~/.github_token

## Elixir
# nss ( for mkcert )
export PATH="/usr/local/opt/nss/bin:$PATH"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# Deno

export DENO_INSTALL="/home/bob/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

export PATH="/usr/local/bin:$PATH"
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

fpath=("$XDG_DATA_HOME/zsh/completions" $fpath)

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

