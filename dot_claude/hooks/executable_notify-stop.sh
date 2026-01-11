#!/bin/bash
# Claude Code Stop hook notification script
# stdin から JSON を受け取り、プロジェクト情報と内容を含めて通知

# stdin から JSON を読み取る
INPUT=$(cat)

# デバッグ: 受け取ったJSONを一時ファイルに保存
echo "$INPUT" > /tmp/claude-hook-debug.json

# jq でフィールドを抽出
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')

# プロジェクト名を取得（ディレクトリ名）
if [ -n "$CWD" ]; then
    PROJECT_NAME=$(basename "$CWD")
else
    PROJECT_NAME=$(basename "$CLAUDE_PROJECT_DIR")
fi

# デフォルトメッセージ
TITLE="Claude Code"
BODY="[$PROJECT_NAME] タスクが完了しました"

# transcript_path からユーザーの最初のプロンプトと結果を抽出
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    # 最初のユーザーテキストメッセージを抽出（type: "user" で content[0].type == "text"）
    FIRST_PROMPT=$(jq -r 'select(.type == "user") | .message.content | if type == "array" then .[] | select(.type == "text") | .text elif type == "string" then . else empty end' "$TRANSCRIPT_PATH" 2>/dev/null | head -n 1)

    # 最後のアシスタントメッセージを抽出
    LAST_RESPONSE=$(tac "$TRANSCRIPT_PATH" | jq -r 'select(.type == "assistant") | .message.content | if type == "array" then [.[] | select(.type == "text") | .text] | join("") elif type == "string" then . else empty end' 2>/dev/null | grep -v '^$' | head -n 1)

    # プロンプトを短縮（80文字まで）- bash変数展開でUTF-8対応
    if [ -n "$FIRST_PROMPT" ]; then
        PROMPT_SHORT="${FIRST_PROMPT:0:80}"
        if [ ${#FIRST_PROMPT} -gt 80 ]; then
            PROMPT_SHORT="${PROMPT_SHORT}..."
        fi
    fi

    # 結果を短縮（150文字まで）- bash変数展開でUTF-8対応
    if [ -n "$LAST_RESPONSE" ]; then
        LAST_RESPONSE="${LAST_RESPONSE//$'\n'/ }"
        RESPONSE_SHORT="${LAST_RESPONSE:0:150}"
        if [ ${#LAST_RESPONSE} -gt 150 ]; then
            RESPONSE_SHORT="${RESPONSE_SHORT}..."
        fi
    fi

    # 通知内容を構築（実際の改行を使用）
    if [ -n "$PROMPT_SHORT" ]; then
        BODY="[$PROJECT_NAME]"$'\n'"📝 $PROMPT_SHORT"
        if [ -n "$RESPONSE_SHORT" ]; then
            BODY="$BODY"$'\n'"✅ $RESPONSE_SHORT"
        fi
    fi
fi

# 通知を送信
notify-send "$TITLE" "$BODY" --icon=dialog-information
