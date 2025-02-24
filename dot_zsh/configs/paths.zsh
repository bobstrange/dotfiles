# Add xdg config home
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"

# $HOME/bin
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

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

# golang
export GOPATH="$HOME/dev"
export PATH="$GOPATH/bin:$PATH"
export GOROOT=$(go env GOROOT)
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

# Android

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Deno

export DENO_INSTALL="/home/bob/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

export PATH="/usr/local/bin:$PATH"
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

fpath=("$XDG_DATA_HOME/zsh/completions" $fpath)
