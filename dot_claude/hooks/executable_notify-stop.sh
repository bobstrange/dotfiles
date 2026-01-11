#!/bin/bash
# Claude Code Stop hook notification script
# stdin から JSON を受け取り、プロジェクト情報を含めて通知

# stdin から JSON を読み取る
INPUT=$(cat)

# jq でプロジェクトディレクトリを抽出（cwd から）
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

# プロジェクト名を取得（ディレクトリ名）
if [ -n "$CWD" ]; then
    PROJECT_NAME=$(basename "$CWD")
else
    PROJECT_NAME=$(basename "$CLAUDE_PROJECT_DIR")
fi

# 通知を送信
notify-send "Claude Code" "[$PROJECT_NAME] タスクが完了しました" --icon=dialog-information
