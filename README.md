# Locker (Only Unix, Windows Functionality addeed later)

An intentionally ugly lock screen with a passphrase, pixelated background, and
random green/red keystroke flashes.

- Passphrase can be any length (min 4 characters), any mix of letters,
  numbers, and symbols.
- Nothing is ever stored in plaintext — each character is salted and
  SHA-256 hashed.
- To submit, press **Enter 3 times within 175ms**. A single Enter does
  nothing.

## Requirements

- Python 3.8+
- `pillow` (`PIL`)

```bash
python3 -m pip install --user pillow
```

On Fedora/Linux, `ImageTk` ships separately from base Pillow:

```bash
sudo dnf install python3-pillow-tk
```

(Debian/Ubuntu: `sudo apt install python3-pil.imagetk`)

`tkinter` is part of the Python standard library, but some Linux distros
split it out — if `import tkinter` fails, install it (`sudo dnf install
python3-tkinter` or `sudo apt install python3-tk`). Windows/Mac installers
from python.org include it by default.

## Setup — both platforms

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

That's the whole cross-platform part. The rest of this README is about
wiring it up to a keyboard shortcut, which works differently per OS.

## Linux (GNOME/Fedora) — keyboard shortcut

Use the included `setup_shortcut.sh`. It registers a GNOME custom
keybinding (default `Ctrl+Alt+L`) that runs `lock.py`.

```bash
bash setup_shortcut.sh
```

To change the key combo, edit `SHORTCUT_KEY` near the top of the script
before running it, or change it later in **Settings > Keyboard > Custom
Shortcuts > Locker**.

### Background pixelation on Linux

`lock.py` tries these screenshot tools, in order, and falls back to a
plain gray background if none are found:

- `gnome-screenshot` (recomended)
- `grim` (Wayland)
- `import` (ImageMagick, X11)
- `scrot` (X11)
- Pillow's built-in `ImageGrab` (works on some Linux setups too)

If your background stays plain gray instead of pixelated, install one of
the above, e.g.:

```bash
sudo dnf install gnome-screenshot     # or: grim, ImageMagick, scrot
```

