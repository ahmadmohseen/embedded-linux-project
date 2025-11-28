# Buildroot - Automated Build System

This directory contains Buildroot-based configurations for building complete embedded Linux systems with minimal manual intervention.

## Overview

Buildroot is a tool that simplifies and automates the process of building a complete embedded Linux system through cross-compilation. It handles:

- Cross-compilation toolchain generation
- Bootloader compilation (U-Boot)
- Linux kernel configuration and build
- Root filesystem creation with BusyBox and packages
- Image generation ready for deployment

## Directory Structure

```
buildroot/
├── README.md                    # This file
├── buildroot/                   # Buildroot source (cloned from upstream)
│   ├── output/                  # QEMU ARM Versatile PB build
│   │   └── images/              # Bootable images for QEMU
│   ├── output-bbb/              # BeagleBone Black build
│   │   └── images/              # Bootable images for BBB
│   └── dl/                      # Downloaded source packages (shared)
└── [future: custom configs]
```

## Buildroot Version

- **Version**: 2024.02.9 (Latest stable release)
- **Source**: https://github.com/buildroot/buildroot.git

---

## QEMU ARM Versatile PB Build

### Configuration

Uses the default `qemu_arm_versatile_defconfig` which provides:
- **Architecture**: ARM926EJ-S (ARMv5)
- **Kernel**: Linux 6.1.44
- **Bootloader**: Built-in QEMU bootloader
- **Root filesystem**: ext2 format
- **Size**: ~60MB
- **Network**: RTL8139 Ethernet (DHCP enabled)

### Building

```bash
cd /home/ahmad/buildroot
make qemu_arm_versatile_defconfig
make -j$(nproc)
```

Build time: ~30-60 minutes (depending on CPU cores and internet speed)

### Running

```bash
cd /home/ahmad/buildroot/output/images
./start-qemu.sh --serial-only
```

**Login**: `root` (no password)

**Exit QEMU**: Press `Ctrl+A`, then `X`

### Testing Network

Once logged in:
```bash
# Check network interface
ifconfig eth0

# Check IP address (should be 10.0.2.15 via DHCP)
ip addr show eth0

# Test connectivity (QEMU provides NAT)
ping -c 3 google.com

# Check DNS resolution
nslookup google.com
```

### Image Locations

All generated files are in: `/home/ahmad/buildroot/output/images/`

- `zImage` - Linux kernel
- `versatile-pb.dtb` - Device tree blob
- `rootfs.ext2` - Root filesystem (ext2 format)
- `start-qemu.sh` - Convenience script to boot QEMU

---

## BeagleBone Black Build

### Configuration

Uses the default `beaglebone_defconfig` which provides:
- **Architecture**: ARM Cortex-A8 (ARMv7)
- **SoC**: TI AM335x
- **Kernel**: Linux (version TBD based on Buildroot config)
- **Bootloader**: U-Boot with MLO (SPL)
- **Root filesystem**: ext4 format
- **Network**: TI CPSW Ethernet driver

### Building

```bash
cd /home/ahmad/buildroot
make O=output-bbb beaglebone_defconfig
make O=output-bbb -j$(nproc)
```

Build time: ~30-60 minutes

### Deploying to SD Card

**Prerequisites**: SD card (minimum 512MB, recommended 4GB+)

#### Step 1: Format SD Card

Use the existing SD card formatting script from the bootloader chapter:

```bash
cd /home/ahmad/embedded-linux-project/manual/bootloader
sudo ./format-sdcard.sh /dev/sdX  # Replace sdX with your SD card device
```

This creates:
- Partition 1 (128MB): FAT32 boot partition
- Partition 2 (remaining): ext4 root filesystem

#### Step 2: Copy Boot Files

```bash
sudo mount /dev/sdX1 /media/$USER/boot
cd /home/ahmad/buildroot/output-bbb/images

# Copy bootloader and kernel
sudo cp MLO u-boot.img zImage am335x-boneblack.dtb /media/$USER/boot/

# Create U-Boot boot script (optional, for auto-boot)
# Or use manual U-Boot commands as in manual build

sudo sync
sudo umount /media/$USER/boot
```

#### Step 3: Extract Root Filesystem

```bash
sudo mount /dev/sdX2 /media/$USER/rootfs
cd /home/ahmad/buildroot/output-bbb/images

# Extract root filesystem
sudo tar -xf rootfs.tar -C /media/$USER/rootfs

sudo sync
sudo umount /media/$USER/rootfs
```

#### Step 4: Boot BeagleBone Black

1. Insert SD card into BBB
2. Connect serial console: `sudo screen /dev/ttyUSB0 115200`
3. Power on BBB (hold BOOT button if booting from SD card)
4. At U-Boot prompt, boot manually or use saved environment

**U-Boot Commands** (if needed):
```
fatload mmc 0:1 0x80200000 zImage
fatload mmc 0:1 0x80f00000 am335x-boneblack.dtb
setenv bootargs console=ttyO0,115200 root=/dev/mmcblk0p2 rootwait
bootz 0x80200000 - 0x80f00000
```

### Testing Network on BBB

Once logged in:
```bash
# Check Ethernet interface
ifconfig eth0

# If not up, bring it up manually
ifup eth0

# Or use static IP
ifconfig eth0 192.168.1.100 netmask 255.255.255.0 up
route add default gw 192.168.1.1

# Test connectivity
ping -c 3 8.8.8.8
```

### Image Locations

All generated files are in: `/home/ahmad/buildroot/output-bbb/images/`

- `MLO` - First-stage bootloader (SPL)
- `u-boot.img` - U-Boot bootloader
- `zImage` - Linux kernel
- `am335x-boneblack.dtb` - Device tree blob
- `rootfs.ext4` - Root filesystem (ext4 format)
- `rootfs.tar` - Root filesystem tarball (easier for extraction)
- `sdcard.img` - Complete SD card image (optional, ready to `dd`)

---

## Customizing Buildroot

### Configuration Menu

To customize the build (add packages, change kernel config, etc.):

```bash
# For QEMU
cd /home/ahmad/buildroot
make menuconfig

# For BeagleBone Black
make O=output-bbb menuconfig
```

### Common Customizations

**Add packages**: Target packages → (choose category) → Select packages

**Kernel configuration**: Kernel → Kernel configuration

**Filesystem options**: Filesystem images → Choose formats, sizes

**Network packages**: Target packages → Networking applications

### Saving Custom Configuration

```bash
# Save current config as a defconfig
make savedefconfig

# Or save to a custom location
make savedefconfig BR2_DEFCONFIG=/home/ahmad/embedded-linux-project/buildroot/custom-bbb.defconfig
```

---

## Comparison: Manual Build vs Buildroot

| Aspect | Manual Build | Buildroot |
|--------|-------------|-----------|
| **Learning Value** | High - understand every step | Medium - automated |
| **Time Investment** | High - each component built separately | Low - one command |
| **Flexibility** | Maximum - full control | High - configurable |
| **Reproducibility** | Manual - requires documentation | Excellent - config file |
| **Package Management** | Manual - track dependencies | Automatic - built-in |
| **Updates** | Manual - rebuild each component | Easy - update config |
| **Initial Setup** | ~5-8 hours | ~1 hour |
| **Subsequent Builds** | ~2-3 hours | ~30-60 minutes |

---

## Troubleshooting

### Build Fails with "No space left on device"

```bash
# Check available space
df -h /home/ahmad

# Clean old builds to free space
make clean              # For QEMU
make O=output-bbb clean # For BBB
```

### Download Errors

Buildroot downloads source packages. If downloads fail:

```bash
# Check internet connection
ping -c 3 google.com

# Retry the build (downloads resume)
make -j$(nproc)
```

### SD Card Not Booting

1. Verify MLO is the first file on the FAT partition
2. Check U-Boot environment variables
3. Verify boot partition is marked as bootable (`fdisk`)
4. Check serial console for error messages

### Network Not Working

On BBB:
- Check cable connection
- Verify interface configuration: `ifconfig -a`
- Check kernel messages: `dmesg | grep eth`
- Try manual interface configuration: `ifup eth0`

---

## Resources

- **Buildroot Manual**: https://buildroot.org/downloads/manual/manual.html
- **BeagleBone Black Documentation**: https://beagleboard.org/black
- **QEMU Documentation**: https://www.qemu.org/docs/master/

---

## Next Steps

After completing the Buildroot builds:

1. Compare the Buildroot images with manual builds
2. Test network configurations on both QEMU and BBB
3. Experiment with adding packages via `make menuconfig`
4. Consider Yocto Project as an alternative build system (next section)

## Status

- [x] Buildroot 2024.02.9 cloned and configured
- [x] QEMU ARM Versatile build completed
- [x] QEMU system tested - boots successfully with network
- [x] BeagleBone Black build completed
- [x] Complete documentation with deployment guides
- [x] Professional automation scripts provided
