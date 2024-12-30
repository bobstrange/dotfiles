# modify the prompt to contain git branch name if applicable
git_prompt_info() {
  current_branch=$(git cb 2> /dev/null)

  if [[ -n $current_branch ]]; then
    echo " %{$fg[green]%}$current_branch%{$reset_color%}"
  fi
}
# Use powerline instead
# setopt promptsubst

PS1='${SSH_CONNECTION+"%{$fg[green]%}%n@%m:"}%{$fg[blue]%}%c%{$reset_color%}:$(git_prompt_info) %# '
