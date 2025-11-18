# Linux Kernel

## What Was Built

- **Kernel Version:** Linux 6.6 (LTS)
- **Targets:** BeagleBone Black (ARM Cortex-A8) and QEMU ARM Versatile PB
- **Build Method:** Cross-compilation using arm-cortex_a8-linux-gnueabihf toolchain

## BeagleBone Black Kernel

**Source directory:** `~/linux-stable/`

### Build Steps

```bash
cd ~/linux-stable
export PATH=~/x-tools/arm-cortex_a8-linux-gnueabihf/bin:$PATH
export ARCH=arm
export CROSS_COMPILE=arm-cortex_a8-linux-gnueabihf-

# Configure for multi-platform ARM support
make mrproper
make multi_v7_defconfig

# Build kernel, modules, and device trees
make -j10 zImage
make -j10 modules
make dtbs
```

### Output Files

- **zImage**: `arch/arm/boot/zImage` (~11MB)
- **Device tree**: `arch/arm/boot/dts/ti/omap/am335x-boneblack.dtb` (~69KB)
- **Modules**: Compiled and ready for installation

### Deployment

```bash
# Mount SD card boot partition
sudo mount /dev/sdb1 /media/ahmad/boot

# Copy kernel and device tree
sudo cp arch/arm/boot/zImage /media/ahmad/boot/
sudo cp arch/arm/boot/dts/ti/omap/am335x-boneblack.dtb /media/ahmad/boot/

# Sync and unmount
sudo sync
sudo umount /media/ahmad/boot
```

### U-Boot Commands

```
fatload mmc 0:1 0x80200000 zImage
fatload mmc 0:1 0x80f00000 am335x-boneblack.dtb
bootz 0x80200000 - 0x80f00000
```

## QEMU ARM Kernel

**Source directory:** `~/linux-stable-qemu/`

### Build Steps

```bash
cd ~/linux-stable-qemu
export PATH=~/x-tools/arm-cortex_a8-linux-gnueabihf/bin:$PATH
export ARCH=arm
export CROSS_COMPILE=arm-cortex_a8-linux-gnueabihf-

# Configure for QEMU Versatile platform
make mrproper
make versatile_defconfig

# Build kernel, modules, and device trees
make -j10 zImage
make -j10 modules
make dtbs
```

### Output Files

- **zImage**: `arch/arm/boot/zImage` (~3.5MB, smaller than BBB)
- **Device tree**: `arch/arm/boot/dts/arm/versatile-pb.dtb` (~9KB)
- **Modules**: Compiled and ready for installation

### Running in QEMU

```bash
QEMU_AUDIO_DRV=none qemu-system-arm \
  -m 256M \
  -nographic \
  -M versatilepb \
  -kernel ~/linux-stable-qemu/arch/arm/boot/zImage \
  -append "console=ttyAMA0,115200" \
  -dtb ~/linux-stable-qemu/arch/arm/boot/dts/arm/versatile-pb.dtb
```

**Exit QEMU:** Press `Ctrl+A` then `x`

## Key Learnings

### Build Strategy
- Maintained separate source directories to avoid overwriting builds
- Used `-j10` (10 cores) for faster compilation
- Both kernels use the same cross-compiler toolchain

### Configuration Differences
- **multi_v7_defconfig**: Full-featured, supports many ARM SoCs including AM335x
- **versatile_defconfig**: Minimal configuration for QEMU testing

### Current Status
- ✅ BeagleBone Black kernel boots successfully to kernel panic (no rootfs)
- ✅ QEMU ARM kernel boots successfully to kernel panic (no rootfs)


