# 🧩 GRUB Multi-User Kernel Config System

This project allows multiple users to manage and boot their own custom kernel configurations using GRUB. Each user's kernel entries are defined in their own config file and added dynamically to the GRUB menu under a unified submenu.

---

## 📁 Project Structure

```
├── users.txt				# List of active users (one per line)
├── scripts/
│   ├── setup.sh			# One-time setup script
│   ├── bulk_setup.sh			# Generate + add configs for all users
│   ├── gen_user_config.sh		# Generate per-user GRUB config
│   ├── add_user_to_40_custom.sh	# Append user config source to 40_custom
│   ├── remove_user_from_40_custom.sh	# Remove a user's block from 40_custom
│   └── cleanup.sh			# Optional cleanup script
```

---

## ⚙️ How It Works

1. Each user gets a config at: `/boot/grub/custom/<username>.cfg`
2. `scripts/gen_user_config.sh` generates menuentries using a given kernel/initrd.
3. `scripts/add_user_to_40_custom.sh` appends a `source` entry into `/etc/grub.d/40_custom`, surrounded by unique tags:
   ```
   # >>> USER: asha
   source /boot/grub/custom/asha.cfg
   # <<< USER: asha
   ```
4. A submenu is expected in `40_custom` like:
   ```bash
   ### BEGIN USER KERNEL SUBMENU ###
   submenu 'User Kernels' {
       # User configs will be inserted here
   }
   ### END USER KERNEL SUBMENU ###
   ```

5. `bulk_setup.sh` does it all for every user listed in `users.txt`.

---

## 🛠️ Usage

### 1. 📄 Add Users

Edit `users.txt` and list one username per line (no leading `#`):

```txt
# List of users who need GRUB boot entries
# Each user will get a .cfg in /boot/grub/custom/
# Uncomment names as needed, or add new ones

# asha
# bharat
# chandan
# deepak
# esha
# farhan
# gopal
# hema
# indira
# jaya
```

---

### 2. ⚙️ Run Setup

```bash
sudo ./scripts/setup.sh
```
This will create the required directories and initial setup.

---

### 3. ⚙️ Run Bulk Setup

```bash
sudo ./scripts/bulk_setup.sh /boot/vmlinuz-<version> /boot/initrd.img-<version>
```

- If no arguments are passed, dummy configs will be generated.
- Otherwise, user configs will include those kernel/initrd paths.

---


### 4. 🔁 Update GRUB

After running `bulk_setup.sh`, it auto-updates GRUB using:

```bash
sudo update-grub
```

---

## 🔍 Example Generated Entry

Inside `/boot/grub/custom/asha.cfg`:

```grub
menuentry "asha: kernel-1" {
    echo "Booting kernel: /boot/vmlinuz-5.19.0-40-generic"
    linux /boot/vmlinuz-5.19.0-40-generic root=UUID=... ro quiet splash
    initrd /boot/initrd.img-5.19.0-40-generic
}

menuentry "asha: kernel-2" {
    echo "Booting kernel: /boot/vmlinuz-5.19.0-40-generic"
    linux /boot/vmlinuz-5.19.0-40-generic root=UUID=... ro drm.debug=0xe quiet splash
    initrd /boot/initrd.img-5.19.0-40-generic
}
```

---

## 🧹 Optional Scripts

- `remove_user_from_40_custom.sh <username>`
  → Cleanly removes a user’s entry from `40_custom`.

- `cleanup.sh`
  → Remove all generated user configs and reset `40_custom`.

---

## 🔐 Notes

- Run as **root** or with `sudo`, as it modifies `/etc/grub.d/40_custom` and writes to `/boot/grub/custom`.
- Make sure `/boot/grub/custom/` exists and is writable.
- Manually edit UUIDs and extra kernel params if needed.

---

## 👨‍💻 Author

Ankit Nautiyal
