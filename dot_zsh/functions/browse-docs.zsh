# Browse docs/<subdir>/ files across ghq-managed repos with fzf.
# Files are grouped by repo name; consecutive entries from the same repo
# show the repo name only on the first line.
# Returns the absolute path of the selected file.
#
# Usage: _browse_docs <subdir> [header]
#   subdir: subdirectory under docs/ to search (e.g. "investigations")
#   header: optional fzf header text (defaults to "Select a <subdir> file")
_browse_docs() {
  local subdir="${1:?Usage: _browse_docs <subdir> [header]}"
  local header="${2:-Select a ${subdir} file}"
  local ghq_root
  ghq_root="$(ghq root)"

  local selected
  selected=$(
    # Collect *.md files from docs/<subdir>/ in each repo
    ghq list |
      while IFS= read -r repo; do
        local dir="${ghq_root}/${repo}/docs/${subdir}"
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
      # Pad repo name to fixed width (20 chars) and deduplicate consecutive names
      awk -F'\t' -v width=20 '{
        repo = substr($1, 1, width)
        if (repo == prev) display = sprintf("%-*s %s", width, "", $2)
        else { prev = repo; display = sprintf("%-*s %s", width, repo, $2) }
        print display "\t" $3
      }' |
      fzf \
        --layout=reverse \
        --tmux center,80%,70% \
        --with-nth=1 \
        --delimiter=$'\t' \
        --preview 'bat --color=always --style=header,grid --line-range :80 {2}' \
        --preview-window='right:60%:wrap' \
        --header="${header}"
  )

  [[ -n "$selected" ]] && echo "${selected##*	}"
}

# Entry point with help and subcommand dispatch
docs() {
  case "${1:-}" in
    -h|--help|help|"")
      echo "Usage: docs <command>"
      echo ""
      echo "Browse docs/ files across ghq-managed repos with fzf preview."
      echo ""
      echo "Commands:"
      echo "  investigations   Browse docs/investigations/"
      echo "  runbooks         Browse docs/runbooks/"
      echo "  plans            Browse docs/plans/"
      echo "  cleanups         Browse docs/cleanup/"
      echo "  ideas            Browse docs/idea/"
      echo "  help             Show this help"
      return 0
      ;;
    investigations) _browse_docs investigations ;;
    runbooks)       _browse_docs runbooks ;;
    plans)          _browse_docs plans ;;
    cleanups)       _browse_docs cleanup ;;
    ideas)          _browse_docs idea ;;
    *)
      echo "Unknown command: $1" >&2
      docs --help >&2
      return 1
      ;;
  esac
}

# Zsh completion for docs subcommands
_docs() {
  local -a subcommands=(
    'investigations:Browse docs/investigations/'
    'runbooks:Browse docs/runbooks/'
    'plans:Browse docs/plans/'
    'cleanups:Browse docs/cleanup/'
    'ideas:Browse docs/idea/'
    'help:Show help'
  )
  _describe 'command' subcommands
}
compdef _docs docs

# Shorthand functions for direct access
investigations() { _browse_docs investigations; }
runbooks()       { _browse_docs runbooks; }
plans()          { _browse_docs plans; }
cleanups()       { _browse_docs cleanup; }
ideas()          { _browse_docs idea; }
