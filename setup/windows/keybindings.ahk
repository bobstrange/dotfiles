; AutoHotkey v2 configuration
; Registry Scancode Map (setup.ps1 で設定):
;   CapsLock  → Left Ctrl
;   Left Alt  → Right Ctrl
;   Left Ctrl → Left Alt

#SingleInstance Force
#UseHook true
SendMode("Input")

; F12 key to reload script
F12::Reload()

; ===== Emacs-like keybindings (exclude terminal and VSCode) =====
IsExcludedApp() {
    processName := WinGetProcessName("A")
    excludedProcesses := ["WindowsTerminal.exe", "cmd.exe", "powershell.exe", "Code.exe"]
    for process in excludedProcesses {
        if (processName = process)
            return true
    }
    return false
}

; Cursor movement
#HotIf !IsExcludedApp()
^b::Send("{Left}")
^f::Send("{Right}")
^p::Send("{Up}")
^n::Send("{Down}")

; Line navigation
^a::Send("{Home}")
^e::Send("{End}")

; Deletion
^k::Send("+{End}{BS}")    ; Select to end of line and backspace
^d::Send("{Del}")
^h::Send("{BS}")

; Alt to Ctrl mappings (Command-like behavior)
!a::Send("^a")        ; Select all
!c::Send("^c")        ; Copy
!f::Send("^f")        ; Find
!l::Send("^l")        ; Location/address bar
!n::Send("^n")        ; New
!t::Send("^t")        ; New tab
!v::Send("^v")        ; Paste
!w::Send("^w")        ; Close tab/window
!x::Send("^x")        ; Cut
!z::Send("^z")        ; Undo
!+z::Send("^+z")      ; Redo
!s::Send("^s")        ; Save
!o::Send("^o")        ; Open
!p::Send("^p")        ; Print
!q::Send("!{F4}")     ; Quit application
#HotIf

; ===== Terminal specific keybindings =====
#HotIf WinActive("ahk_exe WindowsTerminal.exe") or WinActive("ahk_exe cmd.exe") or WinActive("ahk_exe powershell.exe")
!v::Send("^+v")       ; Paste in terminal
!c::Send("^+c")       ; Copy in terminal
#HotIf

; ===== Browser specific keybindings (Chrome & Vivaldi) =====
IsBrowser() {
    return WinActive("ahk_exe chrome.exe") or WinActive("ahk_exe vivaldi.exe")
}

#HotIf IsBrowser()
!+t::Send("^+t")               ; Re-open closed tab
!Tab::Send("^{Tab}")           ; 次のタブ
!+Tab::Send("^+{Tab}")         ; 前のタブ
!+]::Send("^+{Tab}")           ; 前のタブ（{ キー）
!+\::Send("^{Tab}")            ; 次のタブ（} キー）
!r::Send("^r")
!+r::Send("^+r")               ; Hard reload
!d::Send("^d")                 ; Bookmark
!+d::Send("^+d")               ; Bookmark all tabs
#HotIf

; ===== Slack specific =====
#HotIf WinActive("ahk_exe Slack.exe")
!k::Send("^k")        ; Quick switcher
#HotIf

; ===== Window management =====
GetMonitorInfo() {
    try {
        MonitorGet(MonitorGetPrimary(), &MonLeft, &MonTop, &MonRight, &MonBottom)
        return { Left: MonLeft, Top: MonTop, Width: MonRight - MonLeft, Height: MonBottom - MonTop }
    } catch {
        return { Left: 0, Top: 0, Width: SysGet(16), Height: SysGet(17) }
    }
}

ShowDebugMessage(key, action, monitor := "", winInfo := "") {
    message := "Key: " . key . " - Action: " . action
    if (monitor != "")
        message .= "`nMonitor: " . monitor
    if (winInfo != "")
        message .= "`nWindow: " . winInfo
    ToolTip(message, 10, 10)
    SetTimer(() => ToolTip(), -3000)
}

; ウィンドウを左半分に寄せる (Alt + Shift + H)
!+h::{
    try {
        WinGetPos(&x, &y, &w, &h, "A")
        monitor := GetMonitorInfo()
        ShowDebugMessage("Alt+Shift+H", "Left half", "W:" . monitor.Width . " H:" . monitor.Height)
        Sleep(50)
        WinMove(monitor.Left, monitor.Top, monitor.Width // 2, monitor.Height - 40, "A")
    } catch Error as e {
        MsgBox("Error in left move: " . e.message)
    }
}

; ウィンドウを下半分に寄せる (Alt + Shift + J)
!+j::{
    try {
        monitor := GetMonitorInfo()
        ShowDebugMessage("Alt+Shift+J", "Bottom half", "W:" . monitor.Width . " H:" . monitor.Height)
        Sleep(50)
        WinRestore("A")
        Sleep(50)
        WinMove(monitor.Left, monitor.Top + monitor.Height // 2, monitor.Width, monitor.Height // 2 - 40, "A")
    } catch Error as e {
        MsgBox("Error in bottom move: " . e.message)
    }
}

; ウィンドウを上半分に寄せる (Alt + Shift + K)
!+k::{
    try {
        monitor := GetMonitorInfo()
        ShowDebugMessage("Alt+Shift+K", "Top half", "W:" . monitor.Width . " H:" . monitor.Height)
        Sleep(50)
        WinRestore("A")
        Sleep(50)
        WinMove(monitor.Left, monitor.Top, monitor.Width, monitor.Height // 2, "A")
    } catch Error as e {
        MsgBox("Error in top move: " . e.message)
    }
}

; ウィンドウを右半分に寄せる (Alt + Shift + L)
!+l::{
    try {
        monitor := GetMonitorInfo()
        ShowDebugMessage("Alt+Shift+L", "Right half", "W:" . monitor.Width . " H:" . monitor.Height)
        Sleep(50)
        WinRestore("A")
        Sleep(50)
        WinMove(monitor.Left + monitor.Width // 2, monitor.Top, monitor.Width // 2, monitor.Height - 40, "A")
    } catch Error as e {
        MsgBox("Error in right move: " . e.message)
    }
}

; ウィンドウを最大化/元に戻す (Alt + Shift + M)
!+m::{
    ShowDebugMessage("Alt+Shift+M", "Maximize/Restore")
    try {
        if WinGetMinMax("A") = 1
            WinRestore("A")
        else
            WinMaximize("A")
    } catch Error as e {
        MsgBox("Error in maximize/restore: " . e.message)
    }
}
