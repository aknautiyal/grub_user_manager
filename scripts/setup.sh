#!/bin/bash

# setup.sh
# One-time setup for GRUB user kernel manager

set -e
echo ""
# Ensure script is run as root
if [[ "$EUID" -ne 0 ]]; then
	echo "[!] Please run as root (use sudo)."
	exit 1
fi

CUSTOM_DIR="/boot/grub/custom"
GRUB_FILE="/etc/grub.d/40_custom"

echo "[*] Creating $CUSTOM_DIR directory..."
mkdir -p "$CUSTOM_DIR"
chmod 755 "$CUSTOM_DIR"

# Add submenu to 40_custom if not already present
if ! grep -q "### BEGIN USER KERNEL SUBMENU ###" "$GRUB_FILE"; then
	echo "[*] Adding submenu stub to $GRUB_FILE..."
	sudo bash -c "cat >> $GRUB_FILE" <<'EOF'

### BEGIN USER KERNEL SUBMENU ###
submenu 'User Kernels' {
    # User configs will be inserted here
}
### END USER KERNEL SUBMENU ###
EOF
else
	echo "[i] Submenu already exists in $GRUB_FILE"
fi

# Make sure file is executable
chmod +x "$GRUB_FILE"

echo "[✓] GRUB setup completed. Run 'bulk_setup.sh' to generate entries."
