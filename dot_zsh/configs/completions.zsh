# Nix packages: completions are loaded from ~/.nix-profile/share/zsh/site-functions via fpath

# Non-Nix packages completions
command -v mise &>/dev/null && eval "$(mise completion zsh)"
command -v bun &>/dev/null && ([[ -f "$HOME/.bun/_bun" ]] || bun completions) && source "$HOME/.bun/_bun"

