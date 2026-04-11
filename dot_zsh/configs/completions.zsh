# Nix packages: completions are loaded from ~/.nix-profile/share/zsh/site-functions via fpath

# Non-Nix packages completions
command -v mise &>/dev/null && eval "$(mise completion zsh)"

# Case-insensitive and partial matching (e.g. "Dock" → "docker", "c.tom" → "config.toml")
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|.=*' 'l:|=* r:|=*'

# Colorize completion descriptions
zstyle ':completion:*:descriptions' format '%F{cyan}-- %d --%f'
zstyle ':completion:*:messages' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'

# fzf-tab preview: show file content or directory tree
zstyle ':fzf-tab:complete:*' fzf-preview \
  '[[ -d $realpath ]] && eza --tree --color=always --level=2 $realpath || bat --color=always --style=numbers --line-range=:100 $realpath 2>/dev/null'

