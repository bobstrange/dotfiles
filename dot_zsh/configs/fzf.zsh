# Color scheme: GitHub Dark
export FZF_DEFAULT_OPTS='
  --color "bg:#0d1117,bg+:#161b22,fg:#c9d1d9,fg+:#c9d1d9"
  --color "hl:#58a6ff,hl+:#58a6ff"
  --color "info:#8b949e,prompt:#58a6ff,spinner:#58a6ff,pointer:#f85149,marker:#3fb950"
  --color "border:#30363d,header:#8b949e"
  --layout=reverse
  --border=rounded
  --info=inline
  --preview "bat --color=always --style=numbers --line-range=:200 {}"
  --preview-window=right:55%:wrap
  --bind="ctrl-/:toggle-preview"
  --tmux center,90%
'

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -100'"

# File
edit() {
  local files
  IFS=$'\n' files=($(fzf --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# Git
# https://github.com/junegunn/fzf/wiki/examples#git

alias glNoGraph='git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr% C(auto)%an" "$@"'
_gitLogLineToHash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
_viewGitLogLine="$_gitLogLineToHash | xargs -I % sh -c 'git show --color=always % | delta'"

gco() {
  _fzf_git_each_ref --no-multi | xargs git checkout
}

gbr() {
  cd "$(_fzf_git_branches --no-multi)"
}

gsta() {
  _fzf_git_stashes --no-multi | xargs git stash apply
}

gdel() {
  _fzf_git_branches --multi | xargs git branch -D
}

gadd() {
  git ls-files --deleted --modified --other --exclude-standard | \
  fzf \
    --multi \
    --preview 'git diff --color=always {-1}' | \
  xargs git add
}


