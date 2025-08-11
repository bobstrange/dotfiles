# ssh-agent の起動と自動で鍵を追加する設定
# もし ssh-agent が動いていなければ起動し、そうでなければ何もしない
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)"
fi

# 鍵を追加
EMAIL_REGEX="bob.1983.g@gmail.com|bob@spideraf.com"

# ~/.ssh/id_ed25519 が存在し、まだ登録されていない場合のみ実行
if [ -f "$HOME/.ssh/id_ed25519" ] && ! ssh-add -l | grep -qE "$EMAIL_REGEX"; then
  ssh-add "$HOME/.ssh/id_ed25519"
fi
