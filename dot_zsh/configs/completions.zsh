# Nix packages: completions are loaded from ~/.nix-profile/share/zsh/site-functions via fpath

# Non-Nix packages completions
command -v mise &>/dev/null && eval "$(mise completion zsh)"

