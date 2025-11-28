# Root Filesystem Implementation

Complete root filesystem with custom init system, demonstrating embedded Linux userspace development and system integration.

## System Architecture

Built custom root filesystems for two ARM platforms:
- **BeagleBone Black** (ARM Cortex-A8, hard-float)
- **QEMU ARM Versatile PB** (ARM926EJ-S, soft-float)

## Implementation

### Components

1. **BusyBox** - Multi-call binary providing 402 Unix utilities
2. **Init System** - Custom BusyBox init with startup scripts
3. **Libraries** - Essential glibc components from toolchain
4. **Configuration** - System files for proper initialization

### Build Process

#### Step 1: Create Root Filesystems

```bash
sudo ./setup.sh
```

**Creates:**
- FHS-compliant directory structure
- BusyBox installation with 402 symlinks
- Init system configuration
- Essential system files

**Output:** `~/rootfs-bbb/` and `~/rootfs-qemu/`

#### Step 2: Build Kernels with Embedded Initramfs

```bash
sudo ./build-bbb.sh        # BeagleBone Black
sudo ./build-qemu.sh       # QEMU
```

**Process:**
- Creates uncompressed CPIO archive
- Configures kernel with `CONFIG_INITRAMFS_SOURCE`
- Rebuilds kernel with embedded filesystem
- Results in single bootable image

**Output:** Kernel images with built-in root filesystem

## Technical Details

### Directory Structure

```
/
├── bin/          # User commands (BusyBox symlinks)
├── sbin/         # System commands (BusyBox symlinks)
├── usr/
│   ├── bin/      # Additional user commands
│   └── sbin/     # Additional system commands
├── lib/          # Essential shared libraries
├── etc/          # Configuration files
│   ├── init.d/   # Init scripts
│   │   └── rcS   # System startup script
│   ├── inittab   # Init configuration
│   ├── fstab     # Filesystem mount table
│   ├── passwd    # User accounts
│   ├── group     # Group definitions
│   └── ...       # Additional configs
├── dev/          # Device nodes (created at runtime)
├── proc/         # Process information (kernel interface)
├── sys/          # Sysfs (kernel/device information)
├── tmp/          # Temporary files
├── var/log/      # System logs
├── root/         # Root user home
├── home/         # User home directories
└── linuxrc       # Symlink to /bin/busybox
```

### Init System

**`/etc/inittab` Configuration:**
```
::sysinit:/etc/init.d/rcS        # Run startup script
::askfirst:-/bin/sh              # Spawn shell on console
::restart:/sbin/init             # Restart init on signal
::ctrlaltdel:/sbin/reboot        # Handle Ctrl+Alt+Del
::shutdown:/bin/umount -a -r     # Unmount on shutdown
```

**`/etc/init.d/rcS` Startup Script:**
- Mounts essential filesystems (`proc`, `sysfs`, `devtmpfs`)
- Creates device directories
- Sets hostname
- Configures loopback interface
- Establishes environment variables

### Built-in Initramfs

**Advantages:**
- Single kernel image (no separate ramdisk)
- Avoids U-Boot ramdisk format complexities
- Faster boot (no external file loading)
- Simplified deployment

**Implementation:**
- Filesystem packaged as CPIO archive
- Embedded directly in kernel image
- Kernel unpacks to RAM during boot
- Ownership set to root:root (UID/GID 0)

## Deployment

### QEMU Testing

```bash
./test-qemu.sh
```

**Controls:**
- `Ctrl+A` then `X` - Exit QEMU
- `Enter` - Activate console

### BeagleBone Black

#### 1. Deploy to SD Card

```bash
sudo mount /dev/sdb1 /media/ahmad/boot
sudo cp ~/linux-stable/arch/arm/boot/zImage /media/ahmad/boot/
sudo sync
sudo umount /media/ahmad/boot
```

#### 2. U-Boot Boot Sequence

```
fatload mmc 0:1 0x80200000 zImage
fatload mmc 0:1 0x82000000 am335x-boneblack.dtb
setenv bootargs console=ttyS0,115200 rdinit=/sbin/init
bootz 0x80200000 - 0x82000000
```

**Memory Layout:**
- `0x80200000` - Kernel (17MB)
- `0x82000000` - Device tree (avoids overlap)
- `-` - No separate initramfs parameter

## System Specifications

| Feature | BeagleBone Black | QEMU |
|---------|------------------|------|
| **Kernel Size** | 17MB (with initramfs) | 9.8MB (with initramfs) |
| **RootFS Size** | 16MB | 16MB |
| **BusyBox Applets** | 402 | 402 |
| **Boot Time** | ~4 seconds | ~2 seconds |
| **Init** | BusyBox init | BusyBox init |

## Validation

### Test Commands

Once booted:
```bash
ls /              # Verify directory structure
mount             # Check mounted filesystems
ps                # View running processes
uname -a          # Kernel information
cat /proc/cpuinfo # CPU details
ifconfig          # Network interfaces
busybox --list    # Available utilities
```

### Expected Output

```
Please press Enter to activate this console.
~ # uname -a
Linux embedded-linux 6.6.0 #1 Wed Nov 26 2025 armv7l GNU/Linux
~ # mount
proc on /proc type proc (rw,relatime)
sysfs on /sys type sysfs (rw,relatime)
devtmpfs on /dev type devtmpfs (rw,relatime,size=...)
```

## Troubleshooting

### Boot Hang at "Starting kernel..."

**Cause:** Console parameter mismatch
**Solution:** Use `console=ttyS0,115200` (not ttyO0)

### "FDT image overlaps OS image"

**Cause:** Device tree loaded in kernel memory space
**Solution:** Use higher DTB address (`0x82000000`)

### System Appears Frozen After Init

**Cause:** Waiting for user input
**Solution:** Press `Enter` to activate console (askfirst in inittab)

### Screen Terminal Issues

**Cause:** Existing session holding device
**Solution:** 
```bash
screen -ls              # List sessions
kill <PID>              # Kill old session
screen /dev/ttyUSB0 115200  # New session
```

## Technical Implementation Notes

### BusyBox Integration

- **Build:** Statically linked (no library dependencies)
- **Installation:** Single binary with 402 symlinks
- **Configuration:** Default BusyBox config with all applets

### Library Management

- Essential libraries copied from toolchain sysroot
- Static linking preferred for embedded deployment
- Minimal dynamic library set for future expansion

### Init System Design

- **PID 1:** BusyBox init
- **Config:** `/etc/inittab` (simple, proven)
- **Startup:** Single `/etc/init.d/rcS` script
- **Features:** Respawn, askfirst, signal handling

### File Ownership

- CPIO created with `--owner root:root`
- All files owned by UID/GID 0
- Proper security from boot

## Performance Optimizations

- Static linking reduces runtime overhead
- Minimal init system (fast startup)
- Embedded initramfs (no external I/O)
- Optimized directory structure

## Future Enhancements

Potential improvements:
- NFS root for development workflow
- Package manager integration
- Custom application deployment
- Network services (dropbear SSH, etc.)
- Persistent storage configuration

## Files Reference

| File | Purpose |
|------|---------|
| `setup.sh` | Create root filesystems |
| `build-bbb.sh` | Build BBB kernel with initramfs |
| `build-qemu.sh` | Build QEMU kernel with initramfs |
| `test-qemu.sh` | Test in QEMU emulation |
| `uboot-commands.txt` | U-Boot reference commands |

## Technical Skills

This implementation demonstrates:
- ✅ Root filesystem construction from scratch
- ✅ Init system design and implementation
- ✅ BusyBox integration and configuration
- ✅ Kernel initramfs embedding
- ✅ File ownership and permissions management
- ✅ System integration and testing
- ✅ Hardware deployment procedures
