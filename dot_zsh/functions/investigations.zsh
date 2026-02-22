# Browse docs/investigations/ files across ghq-managed repos with fzf.
# Files are grouped by repo name; consecutive entries from the same repo
# show the repo name only on the first line.
# Returns the absolute path of the selected file.
investigations() {
  local ghq_root
  ghq_root="$(ghq root)"

  local selected
  selected=$(
    # Collect *.md files from docs/investigations/ in each repo
    ghq list |
      while IFS= read -r repo; do
        local dir="${ghq_root}/${repo}/docs/investigations"
        if [[ -d "$dir" ]]; then
          find "$dir" -type f -name '*.md' |
            while IFS= read -r f; do
              local name="${f#"${dir}/"}"
              # Output: <repo-short-name>\t<filename>\t<full-path>
              echo "${repo##*/}	${name}	${f}"
            done
        fi
      done |
      # Sort by repo then filename so grouping works correctly
      sort -t$'\t' -k1,1 -k2,2 |
      # Replace duplicate repo names with spaces for cleaner display
      awk -F'\t' '{
        if ($1 == prev) display = sprintf("%-*s %s", len, "", $2)
        else { prev = $1; len = length($1); display = $1 " " $2 }
        print display "\t" $3
      }' |
      fzf \
        --layout=reverse \
        --tmux center,80%,70% \
        --with-nth=1 \
        --delimiter=$'\t' \
        --preview 'bat --color=always --style=header,grid --line-range :80 {2}' \
        --preview-window='right:60%:wrap' \
        --header='Select an investigation file'
  )

  [[ -n "$selected" ]] && echo "${selected##*	}"
}
