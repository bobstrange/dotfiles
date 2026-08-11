# Tool initializations (PATH is set in dot_zshenv)

# mise (replaces rbenv, nodenv, pyenv)
command -v mise &>/dev/null && eval "$(mise activate zsh)"

# golang: GOROOT is intentionally not set. Go derives it from the binary's own
# location, and exporting it means a `brew upgrade go` leaves every inheriting
# shell pointing at a deleted Cellar path ("cannot find GOROOT directory").

# direnv
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# zoxide (jump around with z/zi; keep builtin cd untouched to avoid
# breaking scripted `cd dir && ...` invocations)
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# atuin (shell history)
command -v atuin &>/dev/null && eval "$(atuin init zsh)"

# github token
test -s ~/.github_token && source ~/.github_token

# Note: fpath is set in .zshrc before compinit

