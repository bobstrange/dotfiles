# Color scheme
# molokai https://github.com/junegunn/fzf/wiki/Color-schemes#molokai
export FZF_DEFAULT_OPTS='
--color fg:252,bg:233,hl:67,fg+:252,bg+:235,hl+:81
--color info:144,prompt:161,spinner:135,pointer:135,marker:118
'
# Experimental: use rg as the default source for fzf instead of ag
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'

# To apply the command to CTRL-T and ALT-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"

# File
edit() {
  local files
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# Git
# https://github.com/junegunn/fzf/wiki/examples#git

alias glNoGraph='git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr% C(auto)%an" "$@"'
_gitLogLineToHash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
_viewGitLogLine="$_gitLogLineToHash | xargs -I % sh -c 'git show --color=always % | diff-so-fancy'"

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


