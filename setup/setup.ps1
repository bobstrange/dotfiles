# winget の存在を確認
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget が見つかりません。Windows 10 1809 以降 / App Installer をインストールしてください。"
    exit 1
}

# WSL + Ubuntu のインストール
$wslRunning = (wsl --status 2>$null; $LASTEXITCODE -eq 0)
if ($wslRunning) {
    Write-Host "WSL is already installed"
} else {
    Write-Host "Installing WSL + Ubuntu..."
    wsl --install -d Ubuntu
    Write-Host ""
    Write-Warning "WSL のインストールが完了しました。再起動後に Ubuntu の初期設定（ユーザー名・パスワード）を行ってください。"
    Write-Warning "再起動後に再度このスクリプトを実行すると、Windows アプリのインストールが続行されます。"
    $restart = Read-Host "今すぐ再起動しますか? (y/N)"
    if ($restart -eq "y" -or $restart -eq "Y") {
        Restart-Computer
    }
    exit 0
}

# アプリケーションのリスト (winget ID)
$applications = @(
    # 開発ツール
    "Git.Git",
    "GitHub.GitCredentialManager",
    "Neovim.Neovim",
    "Microsoft.VisualStudioCode",
    "AutoHotkey.AutoHotkey",

    # ブラウザ
    "Google.Chrome",
    "Vivaldi.Vivaldi",

    # 日本語入力
    "Google.JapaneseIME",

    # ユーティリティ
    "Microsoft.PowerToys",
    "voidtools.Everything",
    "7zip.7zip",
    "Notepad++.Notepad++",

    # コミュニケーション
    "SlackTechnologies.Slack",
    "Discord.Discord",

    # メディア
    "VideoLAN.VLC",

    # ノート
    "Obsidian.Obsidian"
)

# winget 未登録のため手動インストールが必要なアプリ
$manualInstall = @(
    "win32yank  - https://github.com/equalsraf/win32yank/releases",
    "NeeView    - https://github.com/neelabo/NeeView/releases"
)

# アプリケーションのインストール
$failed = @()
foreach ($app in $applications) {
    Write-Host "Installing $app..."
    winget install --id $app --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Failed: $app"
        $failed += $app
    }
}

if ($failed.Count -gt 0) {
    Write-Host "`n以下のアプリのインストールに失敗しました:"
    $failed | ForEach-Object { Write-Host "  - $_" }
} else {
    Write-Host "`nすべてのアプリのインストールが完了しました。"
}

Write-Host "`n以下のアプリは winget 未登録のため手動でインストールしてください:"
$manualInstall | ForEach-Object { Write-Host "  - $_" }

Read-Host "`nPress Enter to exit"
