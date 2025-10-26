#!/usr/bin/env bash
unset GTK_PATH
qemu-system-x86_64 \
  -enable-kvm \
  -cpu host \
  -m 4G \
  -smp 4 \
  -cdrom out/JappeOS-*.iso \
  -boot d \
  -bios /usr/share/qemu/OVMF.fd \
  -device virtio-gpu-pci \
  -display gtk,gl=on \
  -vga none
