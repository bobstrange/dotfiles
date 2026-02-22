ghq-look() {
  local src=$(
    ghq list |
      fzf --preview "\
        bat \
        --color=always \
        --style=header,grid \
        --line-range :80 \
        $(ghq root)/{}/README.*\
      "
  )
  if [ -n "$src" ]; then
    BUFFER="cd $(ghq root)/$src"
    zle accept-line
  else
    zle reset-prompt
  fi
}

zle -N ghq-look
# ^@ (Ctrl+Space) conflicts with ibus IME trigger in GTK apps,
# but in terminal emulators (Ghostty) the terminal captures the key first,
# so no conflict occurs. Restored from ^z to ^@.
bindkey "^@" ghq-look # ctrl+space
