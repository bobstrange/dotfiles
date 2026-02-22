#!/bin/bash

# xremap サービス設定スクリプト
# Ubuntu 24.04 GNOME Wayland 対応
#
# This script is idempotent — safe to run multiple times.
# It will overwrite service/autostart files and restart the service.

set -e

echo "🚀 xremap サービスの設定を開始します..."

# 1. 必要なディレクトリを作成
echo "📁 ディレクトリを作成中..."
mkdir -p ~/.config/systemd/user
mkdir -p ~/.config/autostart
mkdir -p ~/.config/xremap

# 2. input グループに追加（必要な場合）
if ! groups | grep -q input; then
  echo "👤 input グループに追加します..."
  sudo usermod -aG input "$USER"
  echo "⚠️  input グループに追加しました。再ログインが必要です。"
  NEED_RELOGIN=true
fi

# 3. xremap のパスを確認
XREMAP_PATH=$(which xremap 2>/dev/null || echo "$HOME/.cargo/bin/xremap")
if [ ! -f "$XREMAP_PATH" ]; then
  echo "❌ xremap が見つかりません。インストールしてください："
  echo "   cargo install xremap --features gnome"
  exit 1
fi
echo "✅ xremap found at: $XREMAP_PATH"

# 4. systemd サービスファイルを作成
echo "📝 systemd サービスファイルを作成中..."
cat >~/.config/systemd/user/xremap.service <<EOF
[Unit]
Description=xremap key remapper
Documentation=https://github.com/xremap/xremap
After=graphical-session.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=3
# Wayland セッション用の環境変数
Environment="DISPLAY=:0"
Environment="WAYLAND_DISPLAY=wayland-0"
# xremap の実行
ExecStart=$XREMAP_PATH $HOME/.config/xremap/config.yml --watch=device
ExecStop=/usr/bin/killall xremap
KillMode=process

[Install]
WantedBy=default.target
EOF

# 5. 自動起動用デスクトップファイルを作成
echo "🖥️  自動起動ファイルを作成中..."
cat >~/.config/autostart/xremap.desktop <<EOF
[Desktop Entry]
Type=Application
Name=xremap
Comment=Key remapper for Linux
Icon=input-keyboard
Exec=systemctl --user start xremap.service
Terminal=false
Hidden=false
X-GNOME-Autostart-enabled=true
EOF

# 6. GNOME Shell 拡張機能の確認
echo "🔍 GNOME Shell 拡張機能を確認中..."
if command -v gnome-extensions &>/dev/null; then
  if gnome-extensions list | grep -q "xremap@k0kubun.com"; then
    echo "✅ GNOME Shell xremap 拡張機能が見つかりました"
    gnome-extensions enable xremap@k0kubun.com 2>/dev/null || true
  else
    echo "⚠️  GNOME Shell xremap 拡張機能がインストールされていません"
    echo "   https://extensions.gnome.org/extension/5060/xremap/ からインストールしてください"
  fi
fi

# 7. systemd ユーザーサービスをリロード
echo "🔄 systemd をリロード中..."
systemctl --user daemon-reload

# 8. サービスを有効化
echo "✨ サービスを有効化中..."
systemctl --user enable xremap.service

# 9. サービスを起動
echo "▶️  サービスを起動中..."
systemctl --user restart xremap.service

# 10. ステータスを確認
echo ""
echo "📊 サービスステータス:"
systemctl --user status xremap.service --no-pager || true

echo ""
echo "✅ 設定が完了しました！"
echo ""
echo "🔧 便利なコマンド:"
echo "  サービス状態確認:  systemctl --user status xremap"
echo "  サービス再起動:    systemctl --user restart xremap"
echo "  サービス停止:      systemctl --user stop xremap"
echo "  サービス開始:      systemctl --user start xremap"
echo "  ログ確認:          journalctl --user -u xremap -f"
echo "  設定ファイル編集:  nano ~/.config/xremap/config.yml"
echo ""

if [ "$NEED_RELOGIN" = "true" ]; then
  echo "⚠️  重要: input グループに追加されました。"
  echo "   完全に有効にするには一度ログアウトして再ログインしてください。"
fi
