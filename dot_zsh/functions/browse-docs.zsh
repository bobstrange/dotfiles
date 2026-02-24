# Collect *.md files from docs/<subdir>/ in each ghq repo with sort keys.
# Output: <sort_key>\t<repo-short-name>\t<filename>\t<full-path> (TSV)
_browse_docs_collect() {
  local ghq_root="$1" subdir="$2"

  zmodload -F zsh/stat b:zstat 2>/dev/null
  ghq list |
    while IFS= read -r repo; do
      dir="${ghq_root}/${repo}/docs/${subdir}"
      if [[ -d "$dir" ]]; then
        fd -t f -e md . "$dir" |
          while IFS= read -r f; do
            name="${f#"${dir}/"}"
            base="${name##*/}"
            if [[ "$base" =~ ^([0-9]{4}-[0-9]{2}-[0-9]{2}) ]]; then
              sort_key="${match[1]}"
            else
              sort_key=$(zstat -F '%Y-%m-%d' +mtime "$f")
            fi
            echo "${sort_key}	${repo##*/}	${name}	${f}"
          done
      fi
    done
}

# Sort by date descending, drop sort key, pad repo name to fixed width.
# Input:  <sort_key>\t<repo-short-name>\t<filename>\t<full-path>
# Output: <display>\t<full-path> (for fzf)
_browse_docs_format() {
  sort -t$'\t' -k1,1r |
    cut -f2- |
    awk -F'\t' -v width=20 '{
      repo = substr($1, 1, width)
      if (repo == prev) display = sprintf("%-*s %s", width, "", $2)
      else { prev = repo; display = sprintf("%-*s %s", width, repo, $2) }
      print display "\t" $3
    }'
}

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
    _browse_docs_collect "$ghq_root" "$subdir" |
      _browse_docs_format |
      fzf \
        --layout=reverse \
        --tmux center,95%,85% \
        --with-nth=1 \
        --delimiter=$'\t' \
        --preview 'bat --color=always --style=header,grid --line-range :80 {2}' \
        --preview-window='right:50%:wrap' \
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
      echo "  cleanups         Browse docs/cleanups/"
      echo "  ideas            Browse docs/ideas/"
      echo "  help             Show this help"
      return 0
      ;;
    investigations) _browse_docs investigations ;;
    runbooks)       _browse_docs runbooks ;;
    plans)          _browse_docs plans ;;
    cleanups)       _browse_docs cleanups ;;
    ideas)          _browse_docs ideas ;;
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
    'cleanups:Browse docs/cleanups/'
    'ideas:Browse docs/ideas/'
    'help:Show help'
  )
  _describe 'command' subcommands
}
compdef _docs docs

# Shorthand functions for direct access
investigations() { _browse_docs investigations; }
runbooks()       { _browse_docs runbooks; }
plans()          { _browse_docs plans; }
cleanups()       { _browse_docs cleanups; }
ideas()          { _browse_docs ideas; }
