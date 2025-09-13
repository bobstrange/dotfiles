command -v sheldon &>/dev/null && eval "$(sheldon completions --shell zsh)"
command -v mise &>/dev/null && eval "$(mise completion zsh)"
command -v bun &>/dev/null && ([[ -f "$HOME/.bun/_bun" ]] || bun completions) && source "$HOME/.bun/_bun"

