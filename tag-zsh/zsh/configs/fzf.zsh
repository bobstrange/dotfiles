# Color scheme
# molokai https://github.com/junegunn/fzf/wiki/Color-schemes#molokai
export FZF_DEFAULT_OPTS='
--color fg:252,bg:233,hl:67,fg+:252,bg+:235,hl+:81
--color info:144,prompt:161,spinner:135,pointer:135,marker:118
'

# Setting ag as the default source for fzf
# export FZF_DEFAULT_COMMAND='ag -g "" --hidden --smart-case'

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
is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

## Browse commit history
gshow() {
  local _gitLogLineToHash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
  local _viewGitLogLine="$_gitLogLineToHash | xargs -I % sh -c 'git show --color=always % | diff-so-fancy'"

  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --no-sort --reverse --tiebreak=index --no-multi \
      --ansi --preview $_viewGitLogLine \
          --preview-window="right:70%" \
          --header "enter to view, alt-y to copy hash" \
          --bind "enter:execute:$_viewGitLogLine   | less -R" \
            --bind "alt-y:execute:$_gitLogLineToHash | pbcopy"
}

# Browse branchs and checkout
gbr() {
  local branches branch
  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "$branches" |
           fzf-tmux \
           --reverse \
           -d 30% \
           --no-multi) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

gco() {
  local _gitDiff='echo {} | sed "s/^\sM\s//" | xargs git diff --color=always | diff-so-fancy'
  local files file
  files=$(git status --short --untracked-files=no)
  file=$(echo "$files" |
         fzf-tmux \
         --reverse -d "70%" \
         --no-multi --no-sort --tiebreak=index \
         --ansi --preview ${_gitDiff} \
         --preview-window="right:80%" \
         ) &&
  echo "$file"
  git checkout -- $(echo "${file}" | sed "s/^\sM\s//")
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
