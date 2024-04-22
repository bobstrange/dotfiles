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

#  git commit browser with previews
gshow() {
  glNoGraph |
    fzf --no-sort --reverse --tiebreak=index --no-multi \
      --ansi --preview="$_viewGitLogLine" \
      --header "enter to view, alt-y to copy hash" \
      --bind "enter:execute:$_viewGitLogLine   | less -R" \
      --bind "alt-y:execute:$_gitLogLineToHash | xclip"
}

# checkout git branch (including remote branches), sorted by most recent commit, limit 30 last branches
gbr() {
  local branches branch
  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) --no-multi) &&
  git stash &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##") &&
  git stash pop
}

# checkout git commit with previews
gco() {
  local commit
  commit=$( glNoGraph |
    fzf --no-sort --reverse --tiebreak=index --no-multi \
        --ansi --preview="$_viewGitLogLine" ) &&
  git stash &&
  git checkout $(echo "$commit" | sed "s/ .*//") &&
  git stash pop
}

# delete git branches
gdel() {
  local branches delete_branches
  branches=$(git --no-pager branch | grep -v )
  delete_branches=$(echo "$branches" | fzf --multi)
  echo "$delete_branches" | sed "s/.* //" | xargs git branch -D
}

# git add with previews
gad() {
  git ls-files --deleted --modified --other --exclude-standard | \
  fzf \
    --multi \
    --preview 'git diff --color=always {-1}' | \
  xargs --no-run-if-empty git add
}

# git stash apply with previews
gsta() {
  git stash list | \
  fzf \
    --exit-0 \
    --no-multi \
    --preview 'git stash show --color=always -p $(echo {} | cut -d: -f1)' \
    --preview-window=down:70% | \
  cut -d: -f1 | \
  xargs --no-run-if-empty git stash apply
}

# Run rspec
fz-rspec() {
  local files target_files
  files=$(git status --short | grep "_spec\.rb$" | sed "s/^...//")
  echo "You could multi select with 'tab' button"
  target_files=$(echo "$files" |
        fzf-tmux \
        --reverse \
        -d 30% \
        --multi \
        ) &&
        echo "$target_files"
  echo "Starting rspec:
$target_files"

  rspec $(echo $target_files | sed "s/\n//")
}
