# Color scheme
# molokai https://github.com/junegunn/fzf/wiki/Color-schemes#molokai
export FZF_DEFAULT_OPTS='
  --color fg:252,bg:233,hl:67,fg+:252,bg+:235,hl+:81
  --color info:144,prompt:161,spinner:135,pointer:135,marker:118
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


