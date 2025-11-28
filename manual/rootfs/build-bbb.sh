#!/bin/bash
# Script to rebuild BBB kernel with built-in initramfs

set -e

KERNEL_SRC=/home/ahmad/linux-stable
ROOTFS=/home/ahmad/rootfs-bbb
INITRAMFS_LIST=/home/ahmad/embedded-linux-project/1-manual-build/4-rootfs/initramfs/initramfs-bbb.cpio
TOOLCHAIN=/home/ahmad/x-tools/arm-cortex_a8-linux-gnueabihf

echo "========================================="
echo "Building BBB Kernel with Built-in Initramfs"
echo "========================================="
echo ""

# First, ensure we have the uncompressed cpio file
if [ ! -f "$INITRAMFS_LIST" ]; then
    echo "Creating uncompressed CPIO archive..."
    cd $ROOTFS
    find . | cpio -H newc -o --owner root:root > $INITRAMFS_LIST
    echo "  ✓ Created: $INITRAMFS_LIST"
fi

cd $KERNEL_SRC

# Set up cross-compilation
export ARCH=arm
export CROSS_COMPILE=arm-cortex_a8-linux-gnueabihf-
export PATH=$TOOLCHAIN/bin:$PATH

echo "Configuring kernel to include initramfs..."
echo ""

# Set the initramfs source in the kernel config
scripts/config --set-str CONFIG_INITRAMFS_SOURCE "$INITRAMFS_LIST"
scripts/config --set-val CONFIG_INITRAMFS_ROOT_UID 0
scripts/config --set-val CONFIG_INITRAMFS_ROOT_GID 0
scripts/config --enable CONFIG_RD_GZIP

echo "  ✓ Configured kernel with initramfs source: $INITRAMFS_LIST"
echo ""

# Rebuild kernel
echo "Building kernel (this will take a few minutes)..."
make -j$(nproc) zImage dtbs

echo ""
echo "========================================="
echo "✓ Kernel with built-in initramfs complete!"
echo "========================================="
echo ""
echo "Kernel size:"
ls -lh arch/arm/boot/zImage
echo ""
echo "Next steps:"
echo "  1. Copy to SD card:"
echo "     sudo mount /dev/sdb1 /media/ahmad/boot"
echo "     sudo cp arch/arm/boot/zImage /media/ahmad/boot/"
echo "     sudo sync"
echo "     sudo umount /media/ahmad/boot"
echo ""
echo "  2. Boot with U-Boot (NO initramfs file needed!):"
echo "     fatload mmc 0:1 0x80200000 zImage"
echo "     fatload mmc 0:1 0x80f00000 am335x-boneblack.dtb"
echo "     setenv bootargs console=ttyO0,115200 rdinit=/sbin/init"
echo "     bootz 0x80200000 - 0x80f00000"
echo ""
echo "  Notice the '-' instead of initramfs address!"
echo ""

