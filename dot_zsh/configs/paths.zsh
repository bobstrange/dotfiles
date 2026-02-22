# Tool initializations (PATH is set in dot_zshenv)

# mise (replaces rbenv, nodenv, pyenv)
command -v mise &>/dev/null && eval "$(mise activate zsh)"

# golang
command -v go &>/dev/null && export GOROOT=$(go env GOROOT)

# direnv
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# zoxide (smart cd)
command -v zoxide &>/dev/null && eval "$(zoxide init zsh --cmd cd)"

# github token
test -s ~/.github_token && source ~/.github_token

# Note: fpath is set in .zshrc before compinit

