#!/bin/bash

# XDG ベースディレクトリを設定（デフォルト: ~/.local/share）
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
COMPLETION_DIR="$XDG_DATA_HOME/zsh/completions"

# Sheldon が利用可能か確認
if ! command -v sheldon &>/dev/null; then
  echo "Sheldon がインストールされていません。" >&2
  exit 1
fi

mkdir -p "$COMPLETION_DIR"
sheldon completions --shell zsh >"$COMPLETION_DIR/_sheldon"

echo "Sheldon の補完ファイルを $COMPLETION_DIR/_sheldon に更新しました。"
