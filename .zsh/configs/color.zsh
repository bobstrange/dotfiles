# makes color constants available
autoload -U colors
colors

# enable colored output from ls, etc. on FreeBSD-based systems
export CLICOLOR=1

# Check for macOS and use gdircolors if available, otherwise dircolors
if [[ "$(uname)" == "Darwin" ]]; then
  [[ -f ${HOME}/.dircolors ]] && eval $(gdircolors -b ${HOME}/.dircolors)
else
  [[ -f ${HOME}/.dircolors ]] && eval $(dircolors -b ${HOME}/.dircolors)
fi

