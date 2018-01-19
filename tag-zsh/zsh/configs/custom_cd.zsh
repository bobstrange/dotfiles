# Override default cd behavior for git root
cd () {
  # Call builtin cd when passed args
  if [ $# -gt 0 ]; then
    builtin cd "$@"
    return
  fi

  # Go to git root when you're in the git repository
  local gitroot=`git rev-parse --show-toplevel 2>/dev/null`
  if [ ! "$gitroot" = "" ]; then
    builtin cd "$gitroot"
    return
  fi

  builtin cd
}
