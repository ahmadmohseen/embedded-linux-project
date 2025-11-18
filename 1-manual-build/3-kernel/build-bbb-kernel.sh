#!/bin/bash
# Build Linux kernel for BeagleBone Black

set -e  # Exit on any error

echo "=== Building Linux Kernel for BeagleBone Black ==="

# Setup toolchain path
export PATH=${HOME}/x-tools/arm-cortex_a8-linux-gnueabihf/bin/:$PATH
export ARCH=arm
export CROSS_COMPILE=arm-cortex_a8-linux-gnueabihf-

# Navigate to kernel source
cd ${HOME}/linux-stable || { echo "ERROR: linux-stable directory not found"; exit 1; }

# Clean previous build
echo "Cleaning previous build..."
make mrproper

# Configure for ARM multi-platform
echo "Configuring kernel (multi_v7_defconfig)..."
make multi_v7_defconfig

# Build kernel image
echo "Building zImage..."
make -j10 zImage

# Build kernel modules
echo "Building modules..."
make -j10 modules

# Build device tree blobs
echo "Building device tree blobs..."
make dtbs

echo ""
echo "=== Build Complete ==="
echo "Kernel image: arch/arm/boot/zImage"
echo "Device tree: arch/arm/boot/dts/ti/omap/am335x-boneblack.dtb"
echo ""
echo "To deploy to SD card:"
echo "  sudo cp arch/arm/boot/zImage /media/ahmad/boot/"
echo "  sudo cp arch/arm/boot/dts/ti/omap/am335x-boneblack.dtb /media/ahmad/boot/"
echo "  sudo sync"

