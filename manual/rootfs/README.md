# Root Filesystem & System Integration

Complete root filesystem with BusyBox and custom init system.

## Quick Start

```bash
sudo ./setup.sh          # Create root filesystems
sudo ./build-bbb.sh      # Build BBB kernel with embedded rootfs
sudo ./build-qemu.sh     # Build QEMU kernel
./test-qemu.sh           # Test in emulation
```

## What It Creates

### Directory Structure
```
/
├── bin/, sbin/, usr/    # BusyBox symlinks (402 utilities)
├── lib/                 # Essential libraries from toolchain
├── etc/                 # Config files (inittab, fstab, passwd, etc.)
├── dev/, proc/, sys/    # Device and kernel interfaces
├── tmp/, var/log/       # Temporary and log files
└── root/, home/         # User directories
```

### Init System

**`/etc/inittab`**: Controls boot behavior
```
::sysinit:/etc/init.d/rcS        # Run startup script
::askfirst:-/bin/sh              # Spawn shell
::restart:/sbin/init             # Handle restart
```

**`/etc/init.d/rcS`**: System startup
- Mount proc, sysfs, devtmpfs
- Set hostname
- Configure loopback network
- Set up environment

## Built-in Initramfs

Instead of separate ramdisk file, filesystem is embedded in kernel:
- Creates CPIO archive of rootfs
- Kernel configured with `CONFIG_INITRAMFS_SOURCE`
- Single bootable zImage with everything included
- Simpler U-Boot commands (no separate initramfs parameter)

## Deployment

### QEMU Testing
```bash
./test-qemu.sh
# Boots in ~2 seconds
# Press Enter to activate console
# Ctrl+A then X to exit
```

### BeagleBone Black

1. **Deploy**:
```bash
sudo mount /dev/sdb1 /media/ahmad/boot
sudo cp ~/linux-stable/arch/arm/boot/zImage /media/ahmad/boot/
sudo sync && sudo umount /media/ahmad/boot
```

2. **Boot** (U-Boot commands):
```
fatload mmc 0:1 0x80200000 zImage
fatload mmc 0:1 0x82000000 am335x-boneblack.dtb
setenv bootargs console=ttyS0,115200 rdinit=/sbin/init
bootz 0x80200000 - 0x82000000
```

Note: DTB at `0x82000000` to avoid overlap with larger kernel

## System Specs

| Feature | BeagleBone Black | QEMU |
|---------|-----------------|------|
| **Kernel** | 17MB (with initramfs) | 9.8MB |
| **RootFS** | 16MB | 16MB |
| **BusyBox** | 402 applets | 402 applets |
| **Boot Time** | ~4 sec | ~2 sec |

## Testing

Once booted:
```bash
ls /              # Check directory structure
mount             # Verify mounted filesystems
ps                # Running processes
uname -a          # Kernel info
busybox --list    # Available commands
ifconfig          # Network interfaces
```

## Common Issues

**Console not responding after boot**  
→ Press Enter (system uses `askfirst` in inittab)

**"FDT image overlaps OS image"**  
→ Device tree address too low, use `0x82000000`

**"Unable to open initial console"**  
→ Device nodes not created, run `sudo ./setup.sh`

## Technical Details

- **BusyBox**: Statically linked, no library dependencies
- **Libraries**: Essential glibc components from toolchain sysroot
- **Init**: BusyBox init (simple, proven design)
- **Ownership**: All files owned by root:root (UID/GID 0)
- **Network**: NSS libraries included for DNS resolution

## Scripts

- `setup.sh` - Create root filesystems
- `build-bbb.sh` - Build BBB kernel with initramfs
- `build-qemu.sh` - Build QEMU kernel with initramfs
- `test-qemu.sh` - Test in QEMU emulation

## Result

✅ Fully functional embedded Linux systems  
✅ Custom init system working  
✅ 402 BusyBox utilities available  
✅ Network loopback operational  
✅ Boots on real hardware (BeagleBone Black)  
✅ Fast boot times (~2-4 seconds)
