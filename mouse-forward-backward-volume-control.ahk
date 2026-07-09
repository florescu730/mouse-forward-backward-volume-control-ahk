#Requires AutoHotkey v2.0
#SingleInstance Force
#UseHook
#NoTrayIcon

; --- AUTOMATIC DEPLOYMENT & INSTALLATION LOGIC ---
if (A_Args.Length > 0 && A_Args[1] = "/install") {
    ; Define secure installation destination in user's local AppData
    installDir := A_AppData "\mouse-forward-backward-volume-control-ahk"
    secureScriptPath := installDir "\mouse-forward-backward-volume-control.ahk"
    
    ; Define Windows startup shortcut path
    startupFolder := A_Startup
    shortcutPath := startupFolder "\mouse-forward-backward-volume-control.lnk"
    
    ; Locate the system's native AutoHotkey UIA executable
    ahkUiaExe := A_ProgramFiles "\AutoHotkey\v2\AutoHotkey64_UIA.exe"
    if (!FileExist(ahkUiaExe)) {
        ahkUiaExe := A_ProgramFiles "\AutoHotkey\v2\AutoHotkey32_UIA.exe"
    }
    
    try {
        ; 1. Ensure the destination directory exists safely
        if (!DirExist(installDir)) {
            DirCreate(installDir)
        }
        
        ; 2. Copy the executing script file to the secure AppData location (overwrite if existing)
        FileCopy(A_ScriptFullPath, secureScriptPath, 1)
        
        ; 3. Create the startup shortcut targeting the secure location wrapped in UIA execution context
        FileCreateShortcut(ahkUiaExe, shortcutPath, installDir, '"' secureScriptPath '"')
        
        MsgBox("Installation successful!`n`nThe script has been copied to a secure system location and will now run automatically at Windows startup.", "Success", 64)
    } catch Error as err {
        MsgBox("Installation failed: " err.Message, "Error", 16)
    }
    ExitApp()
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
    ; Short-circuit: Exit immediately if already at the absolute hardware boundaries
    currentVolume := Round(SoundGetVolume())
    if ((delta > 0 && currentVolume >= 100) || (delta < 0 && currentVolume <= 0)) {
        return
    }

    ; Execute first step immediately
    AdjustVolume(delta)
    
    ; Initial debounce delay before auto-repeat kicks in
    if (!KeyWait(keyName, "T0.4")) {
        
        ; Loop as long as button is held down
        while (GetKeyState(keyName, "P")) {
            ; Check boundary inside the loop to break early during auto-repeat
            currentVolume := Round(SoundGetVolume())
            if ((delta > 0 && currentVolume >= 100) || (delta < 0 && currentVolume <= 0)) {
                break
            }

            AdjustVolume(delta)
            Sleep(REPEAT_DELAY_MS)
        }
        
        ; --- ATOMIC THREAD GATE: ANTI-RACE CONDITION SNAP ---
        ; Forces the volume to snap strictly to the nearest configuration milestone
        ; the exact millisecond the user releases the hardware button.
        currentVolume := Round(SoundGetVolume())
        snappedVolume := Round(currentVolume / VOLUME_STEP) * VOLUME_STEP
        snappedVolume := Min(100, Max(0, snappedVolume))
        
        ; Snap directly to the clean step without sending additional media keys
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
    ; Windows native volume change per media key press (Hardcoded by OS)
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
