$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout"
$regName = "Scancode Map"
$backupPath = Join-Path $PSScriptRoot "scancode_backup.bin"

if (Test-Path $backupPath) {
    $bytes = [System.IO.File]::ReadAllBytes($backupPath)
    Set-ItemProperty -Path $regPath -Name $regName -Value $bytes -Type Binary
    Write-Host "Scancode Map を復元しました。再起動後に有効になります。"
} else {
    Write-Warning "バックアップファイルが見つかりません: $backupPath"
    Write-Host "Scancode Map を削除するとキーリマップがすべて無効になります。"
    $confirm = Read-Host "Scancode Map を削除しますか? (y/N)"
    if ($confirm -eq "y" -or $confirm -eq "Y") {
        Remove-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue
        Write-Host "Scancode Map を削除しました。再起動後に有効になります。"
    } else {
        Write-Host "キャンセルしました。何もしていません。"
    }
}
