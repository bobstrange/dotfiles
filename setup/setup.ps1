# Scoop の存在を確認
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Host "Scoop is already installed"
} else {
    Write-Host "Installing scoop"
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    Write-Host "Finished installing scoop"
}

# Scoop の bucket extras を追加
scoop bucket add extras

# アプリケーションのリスト
$applications = @(
    "git",
    "git-credential-manager",
    "neovim",
    "everything",
    "alacritty",
    "powertoys",
    "obsidian",
    "notepadplusplus",
    "slack",
    "neeview",
    "vscode",
    "7zip",
    "discord"
)

# アプリケーションのインストール
try {
    foreach ($app in $applications) {
        Write-Host "Installing $app..."
        scoop install $app
    }
    Write-Host "Finished installing applications"
} catch {
    Write-Host "Failed installing applications"
    Write-Host $_.Exception.Message
}

# スクリプト終了待ち（任意で削除可）
Read-Host "Press Enter to exit"
