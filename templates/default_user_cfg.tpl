# GRUB config for {{USER}}
# Root UUID: {{UUID}}

menuentry "{{USER}}: kernel-1 (edit me)" {
    linux /boot/{{KERNEL}} root=UUID={{UUID}} ro quiet splash
    initrd /boot/{{INITRD}}
}

menuentry "{{USER}}: kernel-2 (edit me)" {
    linux /boot/{{KERNEL}} root=UUID={{UUID}} ro drm.debug=0xe quiet splash
    initrd /boot/{{INITRD}}
}
