#!/bin/bash

# remove_user_from_40_custom.sh
# Removes a user's GRUB config source line (with tags) from /etc/grub.d/40_custom

set -e

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 <username>"
	exit 1
fi

USER="$1"
CUSTOM_FILE="/etc/grub.d/40_custom"
START_TAG="# >>> USER: ${USER}"
END_TAG="# <<< USER: ${USER}"

# Check if entry exists
if ! grep -qF "$START_TAG" "$CUSTOM_FILE"; then
	echo "[!] No entry found for user '$USER' in 40_custom."
	exit 0
fi

# Remove the tagged block
echo "[*] Removing entry for user '$USER' from 40_custom..."
sudo sed -i "/^$START_TAG$/,/^$END_TAG$/d" "$CUSTOM_FILE"

echo "[✓] Entry removed. You may now run 'sudo update-grub'."
