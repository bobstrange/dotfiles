ghq-look() {
  local repo=$(ghq list|fzf --query "${LBUFFER}")
  if [ -n "${repo}" ]; then
    repo=$(ghq list --full-path --exact ${repo})
    BUFFER="cd ${repo}"
    zle accept-line
  fi
  zle clear-screen
}

zle -N ghq-look
# ^@ binds '^ ' to ghq-look so stop using it
# bindkey "^@" ghq-look # ctrl @
bindkey "^z" ghq-look # ctrl z
