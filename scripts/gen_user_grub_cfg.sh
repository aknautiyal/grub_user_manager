#!/bin/bash

# gen_user_grub_cfg.sh
# Usage: ./gen_user_grub_cfg.sh <username>
# Creates a default kernel config file for the user in /boot/grub/custom/

set -e

if [[ $EUID -ne 0 ]]; then
   echo "[!] Please run this script as root or with sudo"
   exit 1
fi

USER="$1"
TEMPLATE_DIR="$(dirname "$0")/../templates"
TEMPLATE_FILE="${TEMPLATE_DIR}/default_user_cfg.tpl"
UTILS="$(dirname "$0")/grub_utils.sh"

if [[ -z "$USER" ]]; then
    echo "Usage: $0 <username>"
    exit 1
fi

if [[ ! -f "$TEMPLATE_FILE" ]]; then
    echo "[!] Template file not found: $TEMPLATE_FILE"
    exit 1
fi

source "$UTILS"

UUID=$(get_root_uuid)
CFG_FILE=$(user_cfg_path "$USER")

# Dummy kernel names (user can edit later)
KERNEL="vmlinuz-custom"
INITRD="initrd.img-custom"

# Replace placeholders in template
sed -e "s/{{USER}}/${USER}/g" \
    -e "s/{{UUID}}/${UUID}/g" \
    -e "s/{{KERNEL}}/${KERNEL}/g" \
    -e "s/{{INITRD}}/${INITRD}/g" \
    "$TEMPLATE_FILE" | sudo tee "$CFG_FILE" > /dev/null

sudo chmod 644 "$CFG_FILE"

echo "[✓] Created $CFG_FILE"
