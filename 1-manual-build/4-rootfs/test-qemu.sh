#!/bin/bash
# Script to test QEMU with kernel that has built-in initramfs

set -e

KERNEL=~/linux-stable-qemu/arch/arm/boot/zImage
DTB=~/linux-stable-qemu/arch/arm/boot/dts/arm/versatile-pb.dtb

echo "========================================="
echo "Booting QEMU with Built-in Initramfs"
echo "========================================="
echo ""
echo "Kernel: $KERNEL"
echo "DTB:    $DTB"
echo ""

# Check if files exist
if [ ! -f "$KERNEL" ]; then
    echo "✗ Error: Kernel not found at $KERNEL"
    echo "  Build it first: ./rebuild-qemu-kernel-with-initramfs.sh"
    exit 1
fi

if [ ! -f "$DTB" ]; then
    echo "✗ Error: Device tree not found at $DTB"
    exit 1
fi

echo "Starting QEMU..."
echo "  Press Ctrl+A then X to exit QEMU"
echo ""
echo "========================================="
echo ""

# Run QEMU (no -initrd parameter needed!)
QEMU_AUDIO_DRV=none qemu-system-arm \
  -m 256M \
  -nographic \
  -M versatilepb \
  -kernel $KERNEL \
  -dtb $DTB \
  -append "console=ttyAMA0,115200 rdinit=/sbin/init"

echo ""
echo "========================================="
echo "QEMU session ended"
echo "========================================="

