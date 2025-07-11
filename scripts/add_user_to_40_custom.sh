#!/bin/bash

# add_user_to_40_custom.sh
# Usage: ./add_user_to_40_custom.sh <username>
# Adds a GRUB menuentry for the user's .cfg inside the "User Kernels" submenu.

set -e
 
if [[ $EUID -ne 0 ]]; then
   echo "[!] Please run this script as root or with sudo"
   exit 1
fi

USER="$1"
UTILS="$(dirname "$0")/grub_utils.sh"
source "$UTILS"

GRUB_FILE="/etc/grub.d/40_custom"
SUBMENU_TITLE="User Kernels"
CFG_PATH=$(user_cfg_path "$USER")

if [[ -z "$USER" ]]; then
    echo "Usage: $0 <username>"
    exit 1
fi

# Warn if user's .cfg does not exist
if [[ ! -f "$CFG_PATH" ]]; then
    echo "[!] Warning: ${CFG_PATH} does not exist. Continuing anyway."
fi

# Ensure base 40_custom exists
if [[ ! -f "$GRUB_FILE" ]]; then
    echo "[+] Creating new $GRUB_FILE with submenu"
    sudo bash -c "cat > $GRUB_FILE" <<'EOF'
#!/bin/sh
exec tail -n +3 $0

submenu "User Kernels" {
}
EOF
    sudo chmod +x "$GRUB_FILE"
fi

# Check if submenu exists
if ! grep -q "submenu \"${SUBMENU_TITLE}\" {" "$GRUB_FILE"; then
    echo "[+] Inserting ${SUBMENU_TITLE} submenu block"
    sudo sed -i '$ a submenu "'"${SUBMENU_TITLE}"'" {\n}' "$GRUB_FILE"
fi

# Check if user is already listed
if grep -q "/boot/grub/custom/${USER}.cfg" "$GRUB_FILE"; then
    echo "[i] User '$USER' is already in 40_custom. Skipping."
    exit 0
fi

# Insert menuentry for the user inside the submenu
TMP_FILE=$(mktemp)
awk -v user="$USER" -v cfg="$CFG_PATH" '
    BEGIN { added=0 }
    {
        if ($0 ~ /^submenu "User Kernels" {/) {
            print
            next
        }
        if ($0 ~ /^}/ && !added) {
            print "    menuentry \"" user "\x27s kernel config\" {"
            print "        configfile " cfg
            print "    }"
            added=1
        }
        print
    }
' "$GRUB_FILE" | sudo tee "$TMP_FILE" > /dev/null

sudo mv "$TMP_FILE" "$GRUB_FILE"
sudo chmod +x "$GRUB_FILE"

echo "[✓] Added menuentry for $USER to 40_custom"
