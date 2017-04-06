# load zplug configuration
[[ -f $HOME/.zsh/zplug.zsh ]] && source $HOME/.zsh/zplug.zsh
# load custom configurations
for zsh_source in $HOME/.zsh/configs/*.zsh; do
  source $zsh_source
done

if [ "$(uname)"=='Darwin' ]; then

  for zsh_source in $HOME/.zsh/configs/darwin/*.zsh; do
    source $zsh_source
  done
fi

# load aliases
[[ -f $HOME/.aliases ]] && source $HOME/.aliases

autoload -U compinit
compinit

# User configuration
export PATH=$HOME/bin:/usr/local/bin:$PATH

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# nodejs
export PATH=$HOME/.nodebrew/current/bin:$PATH
export PATH=$HOME/.nodebrew/current/bin/npm:$PATH

# pyenv
eval "$(pyenv init -)"

# brew cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# direnv
eval "$(direnv hook zsh)"
 
# Homebrew
if [ -f ~/.brew_github_api_token ]; then
  source ~/.brew_github_api_token
fi

if [ -f ~/.github_api_token ]; then
  source ~/.github_api_token
fi

# go
export GOROOT=/usr/local/Cellar/go
export GOPATH="$HOME/.go"
export PATH="$GOPATH:$PATH"
