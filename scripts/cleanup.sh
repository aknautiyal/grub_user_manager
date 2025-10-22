#!/bin/bash

# cleanup.sh
# Removes all user GRUB configs, submenu entries from 40_custom, and optionally the custom boot dir

set -e
echo ""
# Ensure script is run as root
if [[ "$EUID" -ne 0 ]]; then
	echo "[!] Please run as root (use sudo)."
	exit 1
fi

BIN_PATH="/usr/local/bin/genusrcfg"
COMPLETION_PATH="/etc/bash_completion.d/genusrcfg"

echo "[!] This will REMOVE all per-user GRUB configs and clear 'User Kernels' submenu."
read -rp "Are you sure? [y/N] " confirm
[[ "$confirm" != "y" && "$confirm" != "Y" ]] && exit 0

echo "Cleaning up genusrcfg installation..."

# Remove the genusrcfg binary if it exists
if [ -f "$BIN_PATH" ]; then
    echo "[*] Removing $BIN_PATH..."
    rm -f "$BIN_PATH"
    echo "[✓] Removed genusrcfg binary"
else
    echo "[!] $BIN_PATH not found, skipping"
fi

# Remove bash completion if it exists
if [ -f "$COMPLETION_PATH" ]; then
    echo "Removing $COMPLETION_PATH..."
    rm -f "$COMPLETION_PATH"
    echo "[✓] Removed bash completion"
else
    echo "[!] $COMPLETION_PATH not found, skipping"
fi

# Remove all user config files
echo "[*] Deleting /boot/grub/custom/*.cfg..."
rm -f /boot/grub/custom/*.cfg 2>/dev/null || true

# Reset /etc/grub.d/40_custom to default
GRUB_FILE="/etc/grub.d/40_custom"
if [[ -f "$GRUB_FILE" ]]; then
	echo "[*] Resetting $GRUB_FILE to default stub..."
	sudo bash -c "cat > $GRUB_FILE" <<'EOF'
#!/bin/sh
exec tail -n +3 $0
# This file provides an easy way to add custom menu entries.
# Simply type the menu entries you want to add after this comment.
EOF
chmod +x "$GRUB_FILE"
fi

# Optionally remove the custom directory
read -rp "Remove /boot/grub/custom directory too? [y/N] " remove_custom
if [[ "$remove_custom" == "y" || "$remove_custom" == "Y" ]]; then
	echo "[*] Removing /boot/grub/custom..."
	rm -rf /boot/grub/custom
fi

# Rebuild grub.cfg
echo "[*] Updating GRUB config..."
grub-mkconfig -o /boot/grub/grub.cfg

echo "[✓] GRUB user manager has been cleaned up."
