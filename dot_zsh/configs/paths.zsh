# Tool initializations (PATH is set in dot_zshenv)

# rbenv
command -v rbenv &>/dev/null && eval "$(rbenv init -)"

# nodenv
command -v nodenv &>/dev/null && eval "$(nodenv init -)"

# pyenv
command -v pyenv &>/dev/null && eval "$(pyenv init -)"
command -v pyenv &>/dev/null && eval "$(pyenv virtualenv-init -)" 2>/dev/null

# golang
command -v go &>/dev/null && export GOROOT=$(go env GOROOT)

# direnv
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# github token
test -s ~/.github_token && source ~/.github_token

# Note: fpath is set in .zshrc before compinit

