# mouse-forward-backward-volume-control-ahk

A lightweight and efficient AutoHotkey v2 script that remaps your mouse's side buttons (`XButton1` and `XButton2`) to control the system volume with clean step boundaries and smart auto-repeat handling.

Unlike naive remapping scripts, this project addresses Windows' native asynchronous audio latency by introducing an atomic thread gate. This prevents odd, fragmented volume steps (like 4% or 14%) and guarantees your volume snaps perfectly to rounded milestones. 

Furthermore, by utilizing the native Windows **UIAccess** framework, the script reliably bypasses UAC boundaries, allowing you to control the volume even when elevated administrative windows (like **Task Manager** or **Admin Terminal**) are in focus, without needing to run the script itself as a full Administrator.

## Features
- **Side Button Mapping:** Maps Backward (`XButton1`) to Volume Down and Forward (`XButton2`) to Volume Up.
- **Smart Auto-Repeat:** Pressing once adjusts the volume by a single step; holding the button down triggers continuous adjustment with a fluid 100ms delay.
- **Clean Step Snapping:** Automatically aligns and locks the volume onto precise 10% step boundaries upon button release (0%, 10%, 20% ... 100%).
- **Boundary Optimization:** Short-circuits instantly at 0% or 100% to eliminate UI flicker and redundant system events.
- **Zero Interface Clutter:** Runs completely hidden in the background with no visible system tray icon.
- **Global UIAccess Execution:** Works seamlessly across all elevated system and Admin windows.

---

## Prerequisites
This script requires **AutoHotkey v2.0** or newer installed on your system. 
Download and install the official stable version from the [AutoHotkey Official Website](https://www.autohotkey.com/).

---

## Installation & Setup

The script features a fully automated installation process. To unlock **UIAccess** capability, Windows requires the file to reside in a trusted system directory, so the installer deploys the script directly into `C:\Program Files\AutoHotkey\`.

### Automated Installation

1. Download the `mouse-forward-backward-volume-control.ahk` file from this repository.
2. Open **PowerShell** or **Command Prompt** (standard user context is fine) in the folder where you downloaded the file.
3. Run the script with the `/install` flag:

	mouse-forward-backward-volume-control.ahk /install

4. Windows will prompt a standard UAC dialog to grant temporary administrative privileges for the deployment. 
5. A success dialog will appear. The script is now deployed to `Program Files`, integrated into your Windows Startup, and is already running silently in the background.

### Under the Hood
- **Safe Deployment:** Creates a protected folder under `%ProgramFiles%\AutoHotkey\mouse-forward-backward-volume-control-ahk` and moves the execution file there.
- **Startup Integration:** Configures a dedicated startup shortcut targeting the native `AutoHotkey64_UIA.exe` binary, passing our script as an immutable argument. This triggers the secure UIAccess automation context on boot.

---

## Operations & Management

### Running Hidden (No Tray Icon)
To maintain a clean system interface, the script runs completely hidden in the background with **no visible tray icon** (the green AutoHotkey 'H' icon is hidden natively). It consumes minimal system resources and operates silently.

### How to Close/Stop the Script Manually
Since the script operates without a system tray icon, you cannot right-click it to exit. If you need to stop it without uninstalling:
1. Press `Ctrl + Shift + Esc` to open the Windows **Task Manager**.
2. Under the *Processes* tab, look for **AutoHotkey Unicode Application** (running under your standard user profile context).
3. Right-click it and select **End Task**.

---

## Uninstallation

### Automated Uninstallation
The utility provides an automated cleanup cycle that handles process termination, startup shortcut pruning, and file deletion.

1. Open **PowerShell** or **Command Prompt**.
2. Run the script with the `/uninstall` flag:

	mouse-forward-backward-volume-control.ahk /uninstall

3. Accept the UAC elevation prompt. The script will safely terminate the active background instance, wipe the startup shortcut file from `shell:startup`, and cleanly delete the installation path from `Program Files`.

### Manual Uninstallation
If you no longer have access to the initial download file to pass the flag, you can remove the script manually by following these steps:

1. Open **Task Manager** (`Ctrl + Shift + Esc`) and terminate any active **AutoHotkey Unicode Application** process.
2. Press `Win + R`, type `shell:startup`, and press Enter. Delete the `mouse-forward-backward-volume-control.lnk` shortcut file.
3. Open an elevated/Admin Command Prompt or PowerShell window and run the following command to clean up the deployment directory:
   ```cmd
   rmdir /s /q "C:\Program Files\AutoHotkey\mouse-forward-backward-volume-control-ahk"
---

## License

This project is licensed under the MIT License. See the LICENSE file for details.
