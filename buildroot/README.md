# Buildroot - Automated Build System

One-command build system that generates complete embedded Linux systems.

## Quick Start

```bash
./build.sh qemu  # Build for QEMU
./build.sh bbb   # Build for BeagleBone Black
./build.sh all   # Build both
```

## What is Buildroot?

Automated tool that handles:
- Toolchain generation
- Bootloader compilation (U-Boot)
- Kernel build with device trees
- Root filesystem with BusyBox and packages
- Image generation ready for deployment

**Version**: 2024.02.9 (latest stable)

## QEMU ARM Build

### Build & Run
```bash
cd /home/ahmad/buildroot
make qemu_arm_versatile_defconfig
make -j$(nproc)

# Test
cd output/images
./start-qemu.sh --serial-only
```

**Login**: `root` (no password)  
**Exit**: `Ctrl+A` then `X`

### Test Network
```bash
ifconfig eth0          # Check interface
ping -c 3 google.com   # Test connectivity
```

### Output Files
Location: `/home/ahmad/buildroot/output/images/`
- `zImage` - Kernel
- `versatile-pb.dtb` - Device tree
- `rootfs.ext2` - Root filesystem
- `start-qemu.sh` - Boot script

**Status**: ✅ Complete, tested, network working

## BeagleBone Black Build

### Build
```bash
cd /home/ahmad/buildroot
make O=output-bbb beaglebone_defconfig
make O=output-bbb -j$(nproc)
```

Build time: ~30-60 minutes

### Deploy to SD Card

1. **Format** (using existing script):
```bash
cd ~/embedded-linux-project/manual/bootloader
sudo ./format-sdcard.sh /dev/sdX
```

2. **Copy boot files**:
```bash
sudo mount /dev/sdX1 /media/$USER/boot
cd /home/ahmad/buildroot/output-bbb/images
sudo cp MLO u-boot.img zImage am335x-boneblack.dtb /media/$USER/boot/
sudo sync && sudo umount /media/$USER/boot
```

3. **Extract rootfs**:
```bash
sudo mount /dev/sdX2 /media/$USER/rootfs
sudo tar -xf rootfs.tar -C /media/$USER/rootfs
sudo sync && sudo umount /media/$USER/rootfs
```

4. **Boot** (U-Boot commands if needed):
```
fatload mmc 0:1 0x80200000 zImage
fatload mmc 0:1 0x80f00000 am335x-boneblack.dtb
setenv bootargs console=ttyO0,115200 root=/dev/mmcblk0p2 rootwait
bootz 0x80200000 - 0x80f00000
```

### Output Files
Location: `/home/ahmad/buildroot/output-bbb/images/`
- `MLO` - First-stage bootloader
- `u-boot.img` - U-Boot
- `zImage` - Kernel
- `am335x-boneblack.dtb` - Device tree
- `rootfs.ext4` / `rootfs.tar` - Root filesystem
- `sdcard.img` - Complete SD image (can use `dd`)

**Status**: ✅ Build complete, ready to deploy

## Customization

```bash
make menuconfig              # For QEMU
make O=output-bbb menuconfig # For BBB
```

Add packages under: Target packages → (choose category)

Save config:
```bash
make savedefconfig
```

## Manual vs Buildroot

| Aspect | Manual | Buildroot |
|--------|--------|-----------|
| **Learning** | High - understand everything | Medium - some abstraction |
| **Time** | ~2-3 hours | ~30-60 minutes |
| **Reproducibility** | Manual effort | Automatic with config |
| **Package Management** | Track manually | Built-in |
| **Best For** | Learning internals | Production workflows |

## Troubleshooting

**Out of disk space**:
```bash
df -h /home/ahmad
make clean  # Free up space
```

**Download errors**:
```bash
ping google.com  # Check internet
make -j$(nproc)  # Retry (resumes downloads)
```

**SD card not booting**:
- Verify MLO is first file on FAT partition
- Check serial console for errors
- Verify partitions are correct type

## Status

- [x] Buildroot 2024.02.9 cloned
- [x] QEMU build complete and tested
- [x] QEMU network verified
- [x] BeagleBone Black build complete
- [x] Deployment scripts and documentation ready
