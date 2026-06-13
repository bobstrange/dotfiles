# winget の存在を確認
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget が見つかりません。Windows 10 1809 以降 / App Installer をインストールしてください。"
    exit 1
}

# WSL + Ubuntu のインストール
$wslRunning = ($LASTEXITCODE -eq 0)
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

    # パスワード管理
    "AgileBits.1Password",

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

# AutoHotkey スクリプトをスタートアップフォルダに登録
Write-Host "`n--- AutoHotkey スタートアップ登録 ---"
$ahkSource = Join-Path $PSScriptRoot "keybindings.ahk"
$startupDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$ahkDest = Join-Path $startupDir "keybindings.ahk"

if (Test-Path $ahkSource) {
    Copy-Item -Path $ahkSource -Destination $ahkDest -Force
    Write-Host "keybindings.ahk をスタートアップフォルダに登録しました。"
    Write-Host "  → $ahkDest"
} else {
    Write-Warning "keybindings.ahk が見つかりません: $ahkSource"
}

# ===== キーリマップ (Scancode Map) =====
# スキャンコード対応表:
#   CapsLock  = 0x003A (3A 00)
#   Left Ctrl = 0x001D (1D 00)
#   Left Alt  = 0x0038 (38 00)
#   Right Ctrl = 0xE01D (1D E0)  ※ 拡張キー
#
# エントリ形式: [送り先 2bytes][送り元 2bytes]
Write-Host "`n--- キーリマップ (Scancode Map) ---"
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout"
$regName = "Scancode Map"
$backupPath = Join-Path $PSScriptRoot "scancode_backup.bin"

$existing = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue).$regName
if ($existing -and -not (Test-Path $backupPath)) {
    [System.IO.File]::WriteAllBytes($backupPath, $existing)
    Write-Host "既存の Scancode Map をバックアップしました: $backupPath"
}

$scancodeMap = [byte[]](
    # ヘッダー (固定)
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
    # エントリ数: 3マッピング + null terminator = 4
    0x04, 0x00, 0x00, 0x00,
    # Left Ctrl (1D 00) ← CapsLock (3A 00)
    0x1D, 0x00, 0x3A, 0x00,
    # Right Ctrl (1D E0) ← Left Alt (38 00)
    0x1D, 0xE0, 0x38, 0x00,
    # Left Alt (38 00) ← Left Ctrl (1D 00)
    0x38, 0x00, 0x1D, 0x00,
    # null terminator
    0x00, 0x00, 0x00, 0x00
)

Set-ItemProperty -Path $regPath -Name $regName -Value $scancodeMap -Type Binary
Write-Host "Scancode Map を設定しました。再起動後に有効になります。"
Write-Host "元に戻す場合は restore_scancode.ps1 を実行してください。"

Write-Host "`n--- Google 日本語入力 キー設定 (手動) ---"
Write-Host "Google 日本語入力のキー設定はインストール後に手動で行ってください:"
Write-Host "  1. タスクバーの [あ] を右クリック → [プロパティ]"
Write-Host "  2. [キー設定] タブ → [編集]"
Write-Host "  3. 以下を設定:"
Write-Host "     - 変換 (Henkan)    → ひらがなに入力切替"
Write-Host "     - 無変換 (Muhenkan) → IME を無効化"

Read-Host "`nPress Enter to exit"
