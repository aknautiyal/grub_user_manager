#!/bin/bash

# setup.sh
# Initializes GRUB user management environment on a DUT

set -e

if [[ $EUID -ne 0 ]]; then
   echo "[!] Please run this script as root or with sudo"
   exit 1
fi

echo "[*] Setting up GRUB user manager..."

# Ensure /boot/grub/custom exists
sudo mkdir -p /boot/grub/custom
sudo chmod 755 /boot/grub/custom
echo "[✓] Created /boot/grub/custom"

echo "[*] Overwriting 40_custom with skeleton for submenu entry"
GRUB_FILE="/etc/grub.d/40_custom"
sudo tee "$GRUB_FILE" > /dev/null << 'EOF'
#!/bin/sh
exec tail -n +3 $0
# This file provides an easy way to add custom menu entries.
# Managed by grub-user-manager. Do not edit manually.

submenu "User Kernels" {
	#User entries will be inserted here
}
EOF
sudo chmod +x "$GRUB_FILE"
echo "[✓] Created $GRUB_FILE"
echo "[✓] Setup completed. You can now run bulk_setup.sh or per-user
refresh scripts."
