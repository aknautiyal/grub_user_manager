#!/bin/bash

# grub_utils.sh
# Shared functions used by GRUB user manager scripts

# Returns UUID of the root (/) filesystem
get_root_uuid() {
	local root_dev
	root_dev=$(findmnt -no SOURCE /)
	blkid -s UUID -o value "$root_dev"
}

# Ensures /boot/grub/custom directory exists
ensure_custom_dir() {
	sudo mkdir -p /boot/grub/custom
	sudo chmod 755 /boot/grub/custom
}

# Full path to a user's .cfg file
user_cfg_path() {
	echo "/boot/grub/custom/$1.cfg"
}
