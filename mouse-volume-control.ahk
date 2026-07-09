#Requires AutoHotkey v2.0
#SingleInstance Force
#UseHook
#NoTrayIcon

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
