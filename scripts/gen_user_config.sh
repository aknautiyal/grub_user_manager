#!/bin/bash

# gen_user_config.sh
#
# Generates a GRUB config fragment for a user.
#
# USAGE:
#   sudo ./gen_user_config.sh <username> [kernel_image] [initrd_image] [kernel_deb_file]
#
# EXAMPLES:
#   1. Dummy config:
#        sudo ./gen_user_config.sh alice
#
#   2. With kernel/initrd paths:
#        sudo ./gen_user_config.sh bob vmlinuz-6.6.0 initrd.img-6.6.0
#
#   3. With kernel .deb file:
#        sudo ./gen_user_config.sh charlie "" "" ./linux-image-6.6.0-custom.deb
#
# OUTPUT:
#   ./grub.d/user_<username>.cfg

set -e

# Ensure script is run as root
if [[ "$EUID" -ne 0 ]]; then
	echo "[!] Please run as root (use sudo)."
	exit 1
fi

USER="$1"
KERNEL="$2"
INITRD="$3"
DEB="$4"

if [[ -z "$USER" ]]; then
	echo "Usage: $0 <username> [kernel_image] [initrd_image] [kernel_deb_file]"
	exit 1
fi

CFG_PATH="/boot/grub/custom/${USER}.cfg"

# Get UUID of the root device
ROOT_PART=$(findmnt -no SOURCE /)
UUID=$(blkid -s UUID -o value "$ROOT_PART")

# If .deb file is provided, extract version and construct kernel/initrd paths
if [[ -n "$DEB" ]]; then
	echo "[*] Extracting kernel version from .deb file: $DEB"
	VERSION=$(dpkg-deb -f "$DEB" Version)
	VERSION=${VERSION%%-*}  # Trim at first dash (optional, format-dependent)

	KERNEL="vmlinuz-$VERSION"
	INITRD="initrd.img-$VERSION"
	echo "[*] Using extracted kernel: $KERNEL"
	echo "[*] Using extracted initrd: $INITRD"
fi

# Fallback to dummy values if nothing provided
if [[ -z "$KERNEL" || -z "$INITRD" ]]; then
	KERNEL="vmlinuz-dummy"
	INITRD="initrd.img-dummy"
	echo "[*] Using dummy values: $KERNEL and $INITRD"
fi

# Warn if overwriting existing config
if [[ -f "$CFG_PATH" ]]; then
	echo "[!] Warning: Overwriting existing file: $CFG_PATH"
fi

echo "[*] Writing GRUB config for user: $USER"

cat > "$CFG_PATH" <<EOF
# GRUB config for ${USER}
# Root UUID: ${UUID}

# sudo grub-reboot "User Kernels>${USER}: kernel-1 (edit me)"
# sudo reboot

menuentry "${USER}: kernel-1 (edit me)" {
	echo "Loading ${USER} ${KERNEL}"
	linux /boot/${KERNEL} root=UUID=${UUID} ro quiet splash
	initrd /boot/${INITRD}
}

menuentry "${USER}: kernel-2 (edit me)" {
	echo "Loading ${USER} ${KERNEL}"
	linux /boot/${KERNEL} root=UUID=${UUID} ro drm.debug=0xe quiet splash
	initrd /boot/${INITRD}
}
EOF

echo "[+] GRUB config generated at: $CFG_PATH"
