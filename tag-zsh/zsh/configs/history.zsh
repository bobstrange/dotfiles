setopt hist_ignore_all_dups
setopt hist_ignore_dups

# Appends every command to the history file once it is executed
setopt inc_append_history
# Reloads the history whenever you use it
setopt share_history

# Add timestamp to history
setopt EXTENDED_HISTORY

HISTFILE=~/.zhistory

# History on memory
HISTSIZE=65535
# History on file
SAVEHIST=1000000000


