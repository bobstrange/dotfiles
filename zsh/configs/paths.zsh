# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# nodejs
export PATH=$HOME/.nodebrew/current/bin:$PATH
export PATH=$HOME/.nodebrew/current/bin/npm:$PATH

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
