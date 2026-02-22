runbook() {
  local dir="$HOME/src/github.com/Phybbit/spideraf_umbrella/docs/runbooks"

  if [[ ! -d "$dir" ]]; then
    echo "Runbook directory not found: $dir" >&2
    echo "Make sure spideraf_umbrella is cloned at: ${dir%/docs/runbooks}" >&2
    return 1
  fi

  local preview_cmd
  if command -v bat &>/dev/null; then
    preview_cmd="bat --color=always --language=md --style=plain"
  else
    preview_cmd="cat"
  fi

  local file
  file=$(ls -1 "$dir" | fzf --no-multi \
    --preview "$preview_cmd $dir/{}" \
    --preview-window=right:60%) && nvim "$dir/$file"
}
