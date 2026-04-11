# Nix packages: completions are loaded from ~/.nix-profile/share/zsh/site-functions via fpath

# Non-Nix packages completions
command -v mise &>/dev/null && eval "$(mise completion zsh)"

# fzf-tab preview: show file content or directory tree
zstyle ':fzf-tab:complete:*' fzf-preview \
  '[[ -d $realpath ]] && eza --tree --color=always --level=2 $realpath || bat --color=always --style=numbers --line-range=:100 $realpath 2>/dev/null'

