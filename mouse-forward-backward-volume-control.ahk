#Requires AutoHotkey v2.0
#SingleInstance Force
#UseHook
#NoTrayIcon

; --- AUTOMATIC DEPLOYMENT & INSTALLATION LOGIC ---
if (A_Args.Length > 0) {
    action := A_Args[1]
    
    ; Define persistent paths used by both install and uninstall routines
    installDir := A_ProgramFiles "\AutoHotkey\mouse-forward-backward-volume-control-ahk"
    secureScriptPath := installDir "\mouse-forward-backward-volume-control.ahk"
    shortcutPath := A_Startup "\mouse-forward-backward-volume-control.lnk"

    ; --- UNINSTALL LOGIC ---
    if (action = "/uninstall") {
        ; Elevate to Admin privileges temporarily to remove files from Program Files
        if (!A_IsAdmin) {
            try {
                Run('*RunAs "' A_ScriptFullPath '" /uninstall')
                ExitApp()
            } catch {
                MsgBox("Uninstallation requires Administrative privileges to remove files from Program Files.", "Access Denied", 16)
                ExitApp()
            }
        }

        try {
            ; 1. Remove the startup shortcut if it exists
            if (FileExist(shortcutPath)) {
                FileDelete(shortcutPath)
            }

            ; 2. Force-close any running background instances of this specific script
            DetectHiddenWindows(true)
            if (WinExist(secureScriptPath " ahk_class AutoHotkey")) {
                WinClose(secureScriptPath " ahk_class AutoHotkey")
            }

            ; 3. Clean up the installation directory from Program Files
            if (DirExist(installDir)) {
                DirDelete(installDir, 1) ; 1 forces deletion of files inside
            }

            MsgBox("Uninstallation successful!`n`nThe script and its startup triggers have been completely removed from your system.", "Success", 64)
        } catch Error as err {
            MsgBox("Uninstallation failed: " err.Message, "Error", 16)
        }
        ExitApp()
    }

    ; --- INSTALL LOGIC ---
    if (action = "/install") {
        if (!A_IsAdmin) {
            try {
                Run('*RunAs "' A_ScriptFullPath '" /install')
                ExitApp()
            } catch {
                MsgBox("Installation requires Administrative privileges to deploy into Program Files for UIAccess support.", "Access Denied", 16)
                ExitApp()
            }
        }

        ahkUiaExe := A_ProgramFiles "\AutoHotkey\v2\AutoHotkey64_UIA.exe"
        if (!FileExist(ahkUiaExe)) {
            ahkUiaExe := A_ProgramFiles "\AutoHotkey\v2\AutoHotkey32_UIA.exe"
        }

        try {
            if (!DirExist(installDir)) {
                DirCreate(installDir)
            }

            FileCopy(A_ScriptFullPath, secureScriptPath, 1)
            FileCreateShortcut(ahkUiaExe, shortcutPath, installDir, '"' secureScriptPath '"')
            
            ; Start the script immediately for the active user session using the shortcut
            Run('cmd.exe /c start "" "' shortcutPath '"',, "Hide")

            MsgBox("Installation successful!`n`nThe script has been deployed to Program Files with native UIAccess support and is now running in the background.", "Success", 64)
        } catch Error as err {
            MsgBox("Installation failed: " err.Message, "Error", 16)
        }
        ExitApp()
    }
}

; --- GLOBAL CONFIGURATION ---
global VOLUME_STEP      := 10     ; Volume step in percentage per increase/decrease operation
global REPEAT_DELAY_MS  := 100    ; Delay in milliseconds between steps when holding down the button

; --- HOTKEYS ---
XButton1::VolumeRepeatLoop(-VOLUME_STEP, "XButton1") ; Backward side button
XButton2::VolumeRepeatLoop(VOLUME_STEP, "XButton2")  ; Forward side button

; --- MAIN LOGIC ---

/**
 * Loops the volume adjustment continuously as long as the hotkey remains physically pressed.
 * Implements a thread gate to guarantee clean termination exactly at a step boundary.
 */
VolumeRepeatLoop(delta, keyName) {
    currentVolume := Round(SoundGetVolume())
    if ((delta > 0 && currentVolume >= 100) || (delta < 0 && currentVolume <= 0)) {
        return
    }

    AdjustVolume(delta)
    
    if (!KeyWait(keyName, "T0.4")) {
        while (GetKeyState(keyName, "P")) {
            currentVolume := Round(SoundGetVolume())
            if ((delta > 0 && currentVolume >= 100) || (delta < 0 && currentVolume <= 0)) {
                break
            }

            AdjustVolume(delta)
            Sleep(REPEAT_DELAY_MS)
        }
        
        currentVolume := Round(SoundGetVolume())
        snappedVolume := Round(currentVolume / VOLUME_STEP) * VOLUME_STEP
        snappedVolume := Min(100, Max(0, snappedVolume))
        
        SoundSetVolume(snappedVolume)
    }
}

AdjustVolume(delta) {
    currentVolume := Round(SoundGetVolume())
    targetVolume := CalculateTarget(currentVolume, delta)
    ApplyVolumeChange(targetVolume, delta)
}

CalculateTarget(current, delta) {
    nearestStep := Round(current / VOLUME_STEP) * VOLUME_STEP
    halfStep := VOLUME_STEP / 2
    
    if (delta > 0) {
        if (current >= nearestStep) {
            target := nearestStep + VOLUME_STEP
        } else {
            target := (nearestStep - current <= halfStep) ? (nearestStep + VOLUME_STEP) : nearestStep
        }
    } else {
        if (current <= nearestStep) {
            target := nearestStep - VOLUME_STEP
        } else {
            target := (current - nearestStep <= halfStep) ? (nearestStep - VOLUME_STEP) : nearestStep
        }
    }
    
    return Min(100, Max(0, target))
}

; --- WINDOWS INTERACTION HELPER ---

ApplyVolumeChange(target, delta) {
    static WINDOWS_OSD_STEP := 2 
    
    isIncreasing := (delta > 0)
    mediaKey := isIncreasing ? "{Volume_Up}" : "{Volume_Down}"
    
    if (target >= 100 || target <= 0) {
        boundaryTransit := target >= 100 ? (100 - WINDOWS_OSD_STEP) : (0 + WINDOWS_OSD_STEP)
        SoundSetVolume(boundaryTransit)
        Send(mediaKey)
        return
    }
    
    stepOffset := isIncreasing ? WINDOWS_OSD_STEP : -WINDOWS_OSD_STEP
    transitVolume := target - stepOffset
    
    SoundSetVolume(transitVolume)
    Send(mediaKey)
}
