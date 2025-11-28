#!/bin/bash
# Build Linux kernel for QEMU ARM Versatile PB

set -e  # Exit on any error

echo "=== Building Linux Kernel for QEMU ARM ==="

# Setup toolchain path
export PATH=${HOME}/x-tools/arm-unknown-linux-gnueabi/bin/:$PATH
export ARCH=arm
export CROSS_COMPILE=arm-unknown-linux-gnueabi-

# Navigate to QEMU kernel source
cd ${HOME}/linux-stable-qemu || { echo "ERROR: linux-stable-qemu directory not found"; exit 1; }

# Clean previous build
echo "Cleaning previous build..."
make mrproper

# Configure for QEMU Versatile platform
echo "Configuring kernel (versatile_defconfig)..."
make versatile_defconfig

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
echo "Device tree: arch/arm/boot/dts/arm/versatile-pb.dtb"
echo ""
echo "To run in QEMU:"
echo "  QEMU_AUDIO_DRV=none qemu-system-arm \\"
echo "    -m 256M -nographic -M versatilepb \\"
echo "    -kernel arch/arm/boot/zImage \\"
echo "    -append \"console=ttyAMA0,115200\" \\"
echo "    -dtb arch/arm/boot/dts/arm/versatile-pb.dtb"

