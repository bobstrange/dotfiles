ghq() {
  if [[ $1 == "look" ]]; then
    local repo_path
    repo_path=$(command ghq list --full-path --exact $2)
    cd ${repo_path}
  else
    command ghq "$@"
  fi
}
