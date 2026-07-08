<#
Registers a Windows shortcut with a keyboard shortcut ("hotkey") that runs
lock.py.

Run this once, from PowerShell:

    powershell -ExecutionPolicy Bypass -File setup_shortcut_windows.ps1

Default shortcut: Ctrl+Alt+L (change $ShortcutKey below if you like).

Notes on how this differs from the GNOME version (setup_shortcut.sh):
- Windows has no "register an arbitrary global hotkey" setting like GNOME's
  custom keybindings. Instead, a .lnk shortcut file can carry a "shortcut
  key", and Windows will honor it globally as long as the .lnk lives
  somewhere Explorer indexes it (we use the Start Menu Programs folder).
- Windows shortcut keys are always Ctrl+Alt+<key> (or Ctrl+Shift+<key>);
  you only choose the final key, not the modifiers.
#>

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LockPath = Join-Path $ScriptDir "lock.py"
$ShortcutKey = "L"          # single letter/digit; Windows pairs it with Ctrl+Alt
$ShortcutName = "Locker"

if (-not (Test-Path $LockPath)) {
    Write-Error "Could not find lock.py next to this script at: $LockPath"
    exit 1
}

# Prefer pythonw.exe so no console window flashes when the hotkey fires;
# fall back to python.exe if pythonw isn't available.
$PythonW = Get-Command pythonw.exe -ErrorAction SilentlyContinue
$PythonExe = Get-Command python.exe -ErrorAction SilentlyContinue

if ($PythonW) {
    $TargetExe = $PythonW.Source
} elseif ($PythonExe) {
    $TargetExe = $PythonExe.Source
} else {
    Write-Error "python.exe / pythonw.exe not found on PATH. Install Python first (https://python.org), making sure to check 'Add python.exe to PATH' during install."
    exit 1
}

$StartMenuPrograms = Join-Path ([Environment]::GetFolderPath("StartMenu")) "Programs"
$ShortcutPath = Join-Path $StartMenuPrograms "$ShortcutName.lnk"

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $TargetExe
$Shortcut.Arguments = "`"$LockPath`""
$Shortcut.WorkingDirectory = $ScriptDir
$Shortcut.Hotkey = "CTRL+ALT+$ShortcutKey"
$Shortcut.Description = "Ugly-on-purpose lock screen"
$Shortcut.Save()

Write-Host "Shortcut created at: $ShortcutPath"
Write-Host "Hotkey registered: Ctrl+Alt+$ShortcutKey -> $TargetExe `"$LockPath`""
Write-Host ""
Write-Host "To change the key later, edit `$ShortcutKey in this script and re-run it,"
Write-Host "or right-click the '$ShortcutName' shortcut in the Start Menu, choose"
Write-Host "Properties, and edit the 'Shortcut key' field directly."
