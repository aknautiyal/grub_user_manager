# grub-user-manager Project

## 🚀 Purpose
Set up and manage per-user GRUB boot entries on shared Linux DUTs.
Each user gets a config file and appears in the GRUB "User Kernels" submenu.

---

## 🛠️ One-Time Setup per DUT
```bash
./setup.sh
```
Creates:
- `/boot/grub/custom/`
- `/etc/grub.d/40_custom` with "User Kernels" submenu

---

## 👥 Add Multiple Users
1. Edit `users.txt`:
```
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
2. Run:
```bash
./bulk_setup.sh
```
Creates config files + adds GRUB entries for all users.

---

## 🧑💻 User Workflow
1. Edit your kernel config:
```bash
sudo nano /boot/grub/custom/alice.cfg
```
Example:
```grub
menuentry "alice: 6.8 drm test" {
    linux /boot/vmlinuz-6.8-alice root=UUID=xxxx ro drm.debug=0xe quiet splash
    initrd /boot/initrd.img-6.8-alice
}
```

2. Reboot directly into it:
```bash
sudo grub-reboot "User Kernels>alice's kernel config>alice: 6.8 drm test"
sudo reboot
```

---

## 💡 Tips
- Get root UUID:
```bash
findmnt -no SOURCE / | xargs blkid -s UUID -o value
```
- Editing your own `.cfg`? No need to run `update-grub`

---

## 📁 Project Layout
| File | Purpose |
|------|---------|
| `users.txt` | List of usernames |
| `setup.sh` | Create custom grub env |
| `bulk_setup.sh` | Batch-setup user configs |
| `scripts/gen_user_grub_cfg.sh` | Create user's `.cfg` file |
| `scripts/add_user_to_40_custom.sh` | Add user to GRUB menu |
| `scripts/grub_utils.sh` | Helper functions |
| `templates/default_user_cfg.tpl` | Template used for user cfg generation |
