# Locker (Linux/macOS/Windows)

An intentionally ugly lock screen with a passphrase.

- Passphrase can be any length (min 4 characters), any mix of letters,
  numbers, and symbols.
- Nothing is ever stored in plaintext — each character is salted and
  SHA-256 hashed.
- To submit, press **Enter 3 times within 219.5491ms**. A single Enter does
  nothing.
- Wrong guess? 1000ms lockout, then you start over.

## Requirements

- Python 3.8+
- `tkinter` (part of standard Python, but some Linux distros split it out;
  Windows and macOS installers from python.org include it by default)

On Fedora/RHEL:
```bash
sudo dnf install python3-tkinter
```

On Debian/Ubuntu:
```bash
sudo apt install python3-tk
```

On Windows: install Python from https://python.org (the standard
installer bundles Tk/tkinter — no separate step needed). During install,
make sure "Add python.exe to PATH" is checked.

## Setup

**Linux/macOS:**

1. Download `lock.py` and put it somewhere permanent (not a temp/Downloads
   folder you'll clean out later).
2. Set your passphrase:

   ```bash
   python3 lock.py --setup
   ```

3. Test it:

   ```bash
   python3 lock.py
   ```

   Type your passphrase, then press **Enter 3 times fast** to unlock.

**Windows:**

1. Download `lock.py` and put it somewhere permanent (not a temp/Downloads
   folder you'll clean out later).
2. Set your passphrase (from PowerShell, cmd, or by double-clicking works
   too since `--setup` also triggers automatically on first run):

   ```powershell
   python lock.py --setup
   ```

3. Test it:

   ```powershell
   python lock.py
   ```

   Type your passphrase, then press **Enter 3 times fast** to unlock.

Config/passphrase hash storage location differs by OS: `~/.config/locker/`
on Linux/macOS, `%APPDATA%\Locker\` on Windows. Nothing else about the app
differs between platforms.

## Linux (GNOME/Fedora) — keyboard shortcut

Use the included `setup_shortcut.sh`. It registers a GNOME custom
keybinding (default `Ctrl+Alt+L`) that runs `lock.py`.

```bash
bash setup_shortcut.sh
```

To change the key combo, edit `SHORTCUT_KEY` near the top of the script
before running it, or change it later in **Settings > Keyboard > Custom
Shortcuts > Locker**.

## Windows — keyboard shortcut

Use the included `setup_shortcut_windows.ps1`. It creates a Start Menu
shortcut with a shortcut key (default `Ctrl+Alt+L`) that runs `lock.py`
via `pythonw.exe` (no console window flash).

```powershell
powershell -ExecutionPolicy Bypass -File setup_shortcut_windows.ps1
```

Windows shortcut keys are always `Ctrl+Alt+<key>`, so you can only choose
the final letter — edit `$ShortcutKey` near the top of the script before
running it. You can also change it afterward: find "Locker" in the Start
Menu, right-click > Properties, and edit the "Shortcut key" field.

## Note — Security

Note: This is **NOT** a security feature and is just meant to keep those you dont want to see your laptop out and for a guessing game.
