setopt hist_ignore_all_dups

# Appends every command to the history file once it is executed
setopt inc_append_history
# Reloads the history whenever you use it
setopt share_history

HISTFILE=~/.zhistory
# History on memory
HISTSIZE=4096
# History on file
SAVEHIST=65536
setopt hist_ignore_dups
setopt EXTENDED_HISTORY
