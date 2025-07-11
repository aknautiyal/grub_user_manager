#!/bin/bash

# bulk_setup.sh
# Reads usernames from users.txt and generates configs + adds them to GRUB submenu

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_LIST="${SCRIPT_DIR}/../users.txt"
UTILS="${SCRIPT_DIR}/grub_utils.sh"
GEN_CFG="${SCRIPT_DIR}/gen_user_grub_cfg.sh"
ADD_ENTRY="${SCRIPT_DIR}/add_user_to_40_custom.sh"

# Validate users.txt
if [[ ! -f "$USER_LIST" ]]; then
    echo "[!] users.txt not found in $SCRIPT_DIR"
    exit 1
fi

# Source utils
source "$UTILS"
ensure_custom_dir

# Loop through user list
while read -r user; do
    [[ -z "$user" || "$user" =~ ^# ]] && continue  # Skip blank or commented lines

    echo "[*] Creating GRUB config for user: $user"
    "$GEN_CFG" "$user"

    echo "[*] Adding $user to 40_custom"
    "$ADD_ENTRY" "$user"
done < "$USER_LIST"

# Final GRUB update
echo "[*] Updating GRUB..."
sudo update-grub
echo "[✓] Done setting up all users from users.txt"
