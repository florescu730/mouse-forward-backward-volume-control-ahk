# Mouse Forward/Backward Volume Control (AHK)

A lightweight and efficient AutoHotkey v2 script that remaps your mouse's side buttons (`XButton1` and `XButton2`) to control the system volume with clean step boundaries and smart auto-repeat handling.

Unlike naive remapping scripts, this project addresses Windows' native asynchronous audio latency by introducing an atomic thread gate. This prevents odd, fragmented volume steps (like 4% or 14%) and guarantees your volume snaps perfectly to rounded milestones.

## Features

- **Side Button Mapping:** Maps Backward (`XButton1`) to Volume Down and Forward (`XButton2`) to Volume Up.
- **Smart Auto-Repeat:** Pressing once adjusts the volume by a single step; holding the button down triggers continuous adjustment with a fluid 100ms delay.
- **Clean Step Snapping:** Automatically aligns and locks the volume onto precise 10% step boundaries upon button release (0%, 10%, 20% ... 100%).
- **Boundary Optimization:** Short-circuits instantly at 0% or 100% to eliminate UI flicker and redundant system events.

---

## Installation & Setup Guide

### 1. Install AutoHotkey v2
This script requires **AutoHotkey v2.0** or newer. 
1. Download the official installer from the [AutoHotkey Official Website](https://www.autohotkey.com/).
2. Run the installer and select the current stable **v2** release.

### 2. Download and Run the Script
1. Clone this repository or download the `mouse-forward-backward-volume-control.ahk` file directly.
2. Double-click `mouse-forward-backward-volume-control.ahk` to launch the script. You will see a green **H** icon appear in your Windows system tray, indicating that the script is active.

---

## How to Run Automatically at Windows Startup

To ensure your mouse buttons always control the volume without manually launching the script after every reboot:

1. Press `Win + R` on your keyboard to open the **Run** dialog box.
2. Type `shell:startup` and press **Enter**. This opens your personal Windows Startup folder.
3. **Right-click** your `mouse-forward-backward-volume-control.ahk` file and select **Show more options -> Create shortcut** (or simply hold `Alt` while dragging the file to create a shortcut).
4. Move the newly created shortcut into the opened **Startup** folder.

---

## License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.
