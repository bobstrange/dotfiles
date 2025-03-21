# use emacs mode

bindkey -e

# bindkey -v
# bindkey "^t" vi-cmd-mode
#
# ### ^ は ctrl
# bindkey "^a" beginning-of-line
# bindkey "^e" end-of-line
# bindkey "^f" forward-char
# bindkey "^b" backward-char
# bindkey "^k" kill-line
# bindkey "^d" delete-char
# bindkey "^p" history-search-backward
# bindkey "^n" history-search-forward
# bindkey "^r" history-incremental-search-backward
# bindkey "^y" accept-and-hold
#
# ### ^[ は alt
# bindkey "^[f" vi-forward-word
# bindkey "^[b" vi-backward-word
# bindkey "^[d" delete-word
# bindkey "^[h" backward-delete-word

## zsh autosuggestions
bindkey '^ ' autosuggest-accept

## zsh auto-comoplete

### https://github.com/marlonrichert/zsh-autocomplete/blob/main/README.md#make-tab-go-straight-to-the-menu-and-cycle-there
### tab で menu に移動できるようにする
bindkey '\t' menu-select "$terminfo[kcbt]" menu-select
bindkey -M menuselect '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete
