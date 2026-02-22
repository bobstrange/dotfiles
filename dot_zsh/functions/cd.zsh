# Go to git repository root
function cdr() {
  local gitroot
  gitroot=$(git rev-parse --show-toplevel 2>/dev/null)
  if [ -n "$gitroot" ]; then
    builtin cd "$gitroot"
  else
    echo "Not in a git repository" >&2
    return 1
  fi
}
