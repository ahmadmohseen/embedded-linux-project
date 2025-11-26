#!/bin/bash
# Script to rebuild QEMU kernel with built-in initramfs

set -e

KERNEL_SRC=~/linux-stable-qemu
ROOTFS=~/rootfs-qemu
INITRAMFS_LIST=~/embedded-linux-project/1-manual-build/4-rootfs/initramfs/initramfs-qemu.cpio
TOOLCHAIN=~/x-tools/arm-unknown-linux-gnueabi

echo "========================================="
echo "Building QEMU Kernel with Built-in Initramfs"
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
export CROSS_COMPILE=arm-unknown-linux-gnueabi-
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
echo "To test with QEMU:"
echo "  cd ~/embedded-linux-project/1-manual-build/4-rootfs"
echo "  ./test-qemu-builtin.sh"
echo ""

