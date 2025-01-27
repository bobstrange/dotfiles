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
  fi

  zle clear-screen
}

zle -N ghq-look
# ^@ binds '^ ' to ghq-look so stop using it
# bindkey "^@" ghq-look # ctrl @
bindkey "^z" ghq-look # ctrl z
