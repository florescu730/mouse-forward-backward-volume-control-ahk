# mouse-forward-backward-volume-control-ahk

A lightweight and efficient AutoHotkey v2 script that remaps your mouse's side buttons (`XButton1` and `XButton2`) to control the system volume with clean step boundaries and smart auto-repeat handling.

Unlike naive remapping scripts, this project addresses Windows' native asynchronous audio latency by introducing an atomic thread gate. This prevents odd, fragmented volume steps (like 4% or 14%) and guarantees your volume snaps perfectly to rounded milestones.

## Features
- **Side Button Mapping:** Maps Backward (`XButton1`) to Volume Down and Forward (`XButton2`) to Volume Up.
- **Smart Auto-Repeat:** Pressing once adjusts the volume by a single step; holding the button down triggers continuous adjustment with a fluid 100ms delay.
- **Clean Step Snapping:** Automatically aligns and locks the volume onto precise 10% step boundaries upon button release (0%, 10%, 20% ... 100%).
- **Boundary Optimization:** Short-circuits instantly at 0% or 100% to eliminate UI flicker and redundant system events.
- **Zero Interface Clutter:** Runs completely hidden in the background with no visible system tray icon.

---

## Prerequisites
This script requires **AutoHotkey v2.0** or newer installed on your system. 
Download and install the official stable version from the [AutoHotkey Official Website](https://www.autohotkey.com/).

---

## Installation & Setup

The script features a fully automated installation process. It copies the file to your system's secure `AppData` directory to prevent accidental deletion and configures it to launch automatically on Windows boot.

### Automated Installation

1. Download the `mouse-volume-control.ahk` file from this repository.
2. Open **PowerShell** or **Command Prompt** in the folder where you downloaded the file.
3. Run the script with the `/install` flag:

	mouse-volume-control.ahk /install

4. A success dialog will appear. The script is now deployed to your local profile and will run seamlessly in the background.

### Under the Hood
- **Safe Deployment:** Creates a dedicated directory under `%APPDATA%\mouse-forward-backward-volume-control-ahk` and moves the `mouse-volume-control.ahk` file there.
- **Startup Integration:** Configures a standard startup shortcut targeting the deployed file so it initializes automatically without requiring manual setup.

---

## Operations & Management

### Running Hidden (No Tray Icon)
To maintain a clean system interface, the script runs completely hidden in the background with **no visible tray icon** (the green AutoHotkey 'H' icon is hidden natively). It consumes minimal system resources and operates silently.

### How to Close/Stop the Script
Since the script operates without a system tray icon, you cannot right-click it to exit. To close it manually:
1. Press `Ctrl + Shift + Esc` to open the Windows **Task Manager**.
2. Under the *Processes* tab, look for **AutoHotkey Unicode Application** (or find your script name under background processes).
3. Right-click it and select **End Task**.

---

## Known Limitations (Windows UAC Security)

Because this utility runs with standard user privileges (to keep your system secure and avoid intrusive UAC pop-ups), Windows native security restricts it from intercepting hardware hooks when an elevated window is in focus. 

- **Behavior:** The volume control hotkeys will temporarily stop working and revert to their native functions (or be ignored) whenever an administrative window (e.g., **Task Manager**, **Admin PowerShell/CMD**, or **UAC Prompts**) is actively in focus. 
- **Solution:** Simply click anywhere on a normal window (browser, IDE, desktop) to return focus to standard integrity level, and the shortcuts will resume functioning instantly.

---

## Uninstallation

To completely remove the utility and its startup triggers from your system:
1. Open Task Manager and close the running script process (as explained above).
2. Press `Win + R`, type `shell:startup`, and press Enter. Delete the `mouse-volume-control.lnk` shortcut.
3. Press `Win + R`, type `%APPDATA%`, and press Enter. Delete the `mouse-forward-backward-volume-control-ahk` folder entirely.

---

## License

This project is licensed under the MIT License. See the LICENSE file for details.
