# GRUB config for {{USER}}
# Root UUID: {{UUID}}

# sudo grub-reboot "User Kernels>{{USER}}'s kernel config>{{USER}}: kernel-1 (edit me)"
# sudo reboot

menuentry "{{USER}}: kernel-1 (edit me)" {
    linux /boot/{{KERNEL}} root=UUID={{UUID}} ro quiet splash
    initrd /boot/{{INITRD}}
}

menuentry "{{USER}}: kernel-2 (edit me)" {
    linux /boot/{{KERNEL}} root=UUID={{UUID}} ro drm.debug=0xe quiet splash
    initrd /boot/{{INITRD}}
}
