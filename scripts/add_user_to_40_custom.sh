#!/bin/bash

# add_user_to_40_custom.sh
# Adds source line for user's GRUB config into /etc/grub.d/40_custom
# with start/end tags to allow clean future management

set -e

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 <username>"
	exit 1
fi

USER="$1"
CFG_PATH="/boot/grub/custom/${USER}.cfg"
CUSTOM_FILE="/etc/grub.d/40_custom"
START_TAG="# >>> USER: ${USER}"
END_TAG="# <<< USER: ${USER}"
SOURCE_LINE="source ${CFG_PATH}"

# Check user config exists
if [[ ! -f "$CFG_PATH" ]]; then
	echo "[!] User config not found: $CFG_PATH"
	exit 1
fi

# Remove any previous block for this user
sudo sed -i "/^${START_TAG}$/,/^${END_TAG}$/d" "$CUSTOM_FILE"

# Insert after the placeholder line
sudo sed -i "/# User configs will be inserted here/a\\
${START_TAG}\\
${SOURCE_LINE}\\
${END_TAG}
" "$CUSTOM_FILE"

echo "[✓] Tagged entry for $USER inserted into submenu"
