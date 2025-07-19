#!/bin/bash

# bulk_setup.sh
# For all uncommented users in users.txt:
#   - Generates GRUB config using gen_user_config.sh
#   - Adds a tagged source entry via add_user_to_40_custom.sh
#   - Runs update-grub at the end

set -e

#--- Input
KERNEL="$1"
INITRD="$2"

#--- Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_LIST_FILE="${SCRIPT_DIR}/../users.txt"
GEN_SCRIPT="${SCRIPT_DIR}/gen_user_config.sh"
ADD_SCRIPT="${SCRIPT_DIR}/add_user_to_40_custom.sh"
CUSTOM_CFG_DIR="/boot/grub/custom"

#--- Check prerequisites
if [[ "$EUID" -ne 0 ]]; then
	echo "[!] Please run as root (use sudo)"
	exit 1
fi

[[ ! -f "$USER_LIST_FILE" ]] && { echo "[!] Missing $USER_LIST_FILE"; exit 1; }
[[ ! -x "$GEN_SCRIPT" ]] && { echo "[!] Cannot execute $GEN_SCRIPT"; exit 1; }
[[ ! -x "$ADD_SCRIPT" ]] && { echo "[!] Cannot execute $ADD_SCRIPT"; exit 1; }

mkdir -p "$CUSTOM_CFG_DIR"

echo "[*] Kernel: ${KERNEL:-<dummy>}"
echo "[*] Initrd: ${INITRD:-<dummy>}"
echo

#--- Process each user
while IFS= read -r USER; do
	[[ -z "$USER" || "$USER" =~ ^[[:space:]]*# ]] && continue
	USER=$(echo "$USER" | xargs)

	echo "[*] Setting up user: $USER"

    # Generate user config
    if [[ -n "$KERNEL" && -n "$INITRD" ]]; then
	    "$GEN_SCRIPT" "$USER" "$KERNEL" "$INITRD"
    else
	    "$GEN_SCRIPT" "$USER"
    fi

    # Add entry to 40_custom via helper script
    "$ADD_SCRIPT" "$USER"
    echo
done < "$USER_LIST_FILE"

#--- Update GRUB
echo "[*] Updating GRUB..."
if command -v update-grub >/dev/null; then
	update-grub
elif command -v grub-mkconfig >/dev/null; then
	grub-mkconfig -o /boot/grub/grub.cfg
else
	echo "[!] Cannot find update-grub or grub-mkconfig"
	exit 1
fi

echo "[✓] Bulk GRUB setup complete"
