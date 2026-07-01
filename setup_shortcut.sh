#!/usr/bin/env bash
# Registers a GNOME custom keyboard shortcut that runs lock.py.
# Run this once: bash setup_shortcut.sh
# Default shortcut: Ctrl+Alt+L  (change SHORTCUT_KEY below if you like)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCK_PATH="$SCRIPT_DIR/lock.py"
SHORTCUT_KEY="<Control><Alt>l"
SHORTCUT_NAME="Locker"

MEDIA_KEYS_SCHEMA="org.gnome.settings-daemon.plugins.media-keys"
CUSTOM_SCHEMA="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding"
CUSTOM_BASE_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

# Find a free custom-keybindingN slot
existing=$(gsettings get "$MEDIA_KEYS_SCHEMA" custom-keybindings)
i=0
while echo "$existing" | grep -q "custom$i/"; do
  i=$((i+1))
done
NEW_PATH="$CUSTOM_BASE_PATH/custom$i/"

# Add the new path to the list
if [ "$existing" = "@as []" ]; then
  new_list="['$NEW_PATH']"
else
  new_list=$(echo "$existing" | sed "s|]|, '$NEW_PATH']|")
fi
gsettings set "$MEDIA_KEYS_SCHEMA" custom-keybindings "$new_list"

gsettings set "$CUSTOM_SCHEMA:$NEW_PATH" name "$SHORTCUT_NAME"
gsettings set "$CUSTOM_SCHEMA:$NEW_PATH" command "python3 $LOCK_PATH"
gsettings set "$CUSTOM_SCHEMA:$NEW_PATH" binding "$SHORTCUT_KEY"

echo "Shortcut registered: $SHORTCUT_KEY -> python3 $LOCK_PATH"
echo "Change the key combo any time in Settings > Keyboard > Custom Shortcuts (\"$SHORTCUT_NAME\")."
