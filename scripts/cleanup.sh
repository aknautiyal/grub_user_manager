#!/bin/bash

# cleanup.sh
# Removes user GRUB configs, 40_custom submenu entries, and the custom boot dir

set -e

echo "[!] This will REMOVE all per-user GRUB configs and clear 'User Kernels' submenu."
read -rp "Are you sure? [y/N] " confirm
[[ "$confirm" != "y" && "$confirm" != "Y" ]] && exit 0

# Remove all /boot/grub/custom/*.cfg
echo "[*] Deleting /boot/grub/custom/*.cfg..."
sudo rm -f /boot/grub/custom/*.cfg

# Reset 40_custom to original stub
GRUB_FILE="/etc/grub.d/40_custom"
if [[ -f "$GRUB_FILE" ]]; then
    echo "[*] Resetting $GRUB_FILE..."
    sudo bash -c "cat > $GRUB_FILE" <<'EOF'
#!/bin/sh
exec tail -n +3 $0
# This file provides an easy way to add custom menu entries.
# Simply type the menu entries you want to add after this comment.
EOF
    sudo chmod +x "$GRUB_FILE"
fi

# Optionally remove the directory
read -rp "Remove /boot/grub/custom directory too? [y/N] " remove_custom
if [[ "$remove_custom" == "y" || "$remove_custom" == "Y" ]]; then
    echo "[*] Removing /boot/grub/custom"
    sudo rm -rf /boot/grub/custom
fi

# Final grub update
echo "[*] Updating grub..."
sudo update-grub

echo "[✓] GRUB user manager has been cleaned up."
