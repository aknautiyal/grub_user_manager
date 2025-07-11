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

# Create base 40_custom if missing
GRUB_FILE="/etc/grub.d/40_custom"
if [[ ! -f "$GRUB_FILE" ]]; then
    echo "[*] Creating /etc/grub.d/40_custom..."
    sudo bash -c "cat > $GRUB_FILE" <<'EOF'
#!/bin/sh
exec tail -n +3 $0
# This file provides an easy way to add custom menu entries.
# Simply type the menu entries you want to add after this comment.
exec tail -n +3 $0
EOF
    sudo chmod +x "$GRUB_FILE"
    echo "[✓] Created $GRUB_FILE"
else
    echo "[i] $GRUB_FILE already exists"
fi

# Update GRUB once
echo "[*] Running update-grub..."
sudo update-grub

echo "[✓] Setup complete."
