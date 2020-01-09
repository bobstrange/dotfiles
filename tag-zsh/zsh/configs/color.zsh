# makes color constants available
autoload -U colors
colors

# enable colored output from ls, etc. on FreeBSD-based systems
export CLICOLOR=1
[[ -f ${HOME}/.dircolors ]] && eval $(dircolors -b ${HOME}/.dircolors)
