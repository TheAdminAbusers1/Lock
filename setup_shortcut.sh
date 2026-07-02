#!/usr/bin/env bash
# Registers a GNOME custom keyboard shortcut that runs lock.py.
# Run this once: bash setup_shortcut.sh
# Default shortcut: Ctrl+Alt+L  (change SHORTCUT_KEY below if you like)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCK_PATH="$SCRIPT_DIR/lock.py"
SHORTCUT_KEY="<Control><Alt>l"
SHORTCUT_NAME="Locker"

# Resolve a real python3 path so the shortcut works even if it's run from
# a shell with a different PATH than gnome-shell's.
PYTHON_BIN="$(command -v python3 || true)"
if [ -z "$PYTHON_BIN" ]; then
  echo "python3 not found on PATH. Install python3 first." >&2
  exit 1
fi

if [ ! -f "$LOCK_PATH" ]; then
  echo "Could not find lock.py next to this script at: $LOCK_PATH" >&2
  exit 1
fi

if ! command -v gsettings >/dev/null 2>&1; then
  echo "gsettings not found. This script only works on GNOME." >&2
  exit 1
fi

MEDIA_KEYS_SCHEMA="org.gnome.settings-daemon.plugins.media-keys"
CUSTOM_SCHEMA="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding"
CUSTOM_BASE_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

# Read the existing list of custom keybinding paths.
existing="$(gsettings get "$MEDIA_KEYS_SCHEMA" custom-keybindings)"

# Extract already-used custom keybinding indices (robust to spacing/order),
# so we pick a slot name that isn't taken instead of assuming custom0,
# custom1, ... are contiguous.
used_indices="$(echo "$existing" | grep -oE "custom[0-9]+" | grep -oE "[0-9]+" | sort -n -u || true)"
i=0
while echo "$used_indices" | grep -qx "$i"; do
  i=$((i + 1))
done
NEW_PATH="${CUSTOM_BASE_PATH}/custom${i}/"

# Build the new custom-keybindings list by parsing existing entries into an
# array, rather than string-splicing (which breaks on "@as []", trailing
# commas, or unusual whitespace).
if [ "$existing" = "@as []" ]; then
  paths=()
else
  # Strip the surrounding [ ] then split on commas.
  inner="${existing#\[}"
  inner="${inner%\]}"
  IFS=',' read -ra raw_paths <<< "$inner"
  paths=()
  for p in "${raw_paths[@]}"; do
    # Trim whitespace and surrounding quotes.
    p="$(echo "$p" | sed -e "s/^[[:space:]]*//" -e "s/[[:space:]]*$//")"
    p="${p#\'}"
    p="${p%\'}"
    [ -n "$p" ] && paths+=("$p")
  done
fi
paths+=("$NEW_PATH")

# Reassemble as a GNOME array-of-strings literal: ['a', 'b', 'c']
new_list="["
for idx in "${!paths[@]}"; do
  [ "$idx" -gt 0 ] && new_list+=", "
  new_list+="'${paths[$idx]}'"
done
new_list+="]"

gsettings set "$MEDIA_KEYS_SCHEMA" custom-keybindings "$new_list"
gsettings set "${CUSTOM_SCHEMA}:${NEW_PATH}" name "$SHORTCUT_NAME"
gsettings set "${CUSTOM_SCHEMA}:${NEW_PATH}" command "$PYTHON_BIN $LOCK_PATH"
gsettings set "${CUSTOM_SCHEMA}:${NEW_PATH}" binding "$SHORTCUT_KEY"

echo "Shortcut registered: $SHORTCUT_KEY -> $PYTHON_BIN $LOCK_PATH"
echo "Change the key combo any time in Settings > Keyboard > Custom Shortcuts (\"$SHORTCUT_NAME\")."
