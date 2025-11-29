# Manual Builds

Building embedded Linux systems from scratch to understand how everything fits together.

## What's Here

Complete implementation of all layers:
1. Cross-compilation toolchains (`toolchain/`)
2. U-Boot bootloader (`bootloader/`)
3. Linux kernel with device trees (`kernel/`)
4. Root filesystem and init system (`rootfs/`)

## Build Pipeline

### 1. Toolchains
Two ARM toolchains built with crosstool-NG:
- **arm-cortex_a8-linux-gnueabihf** - For BeagleBone Black (hard-float)
- **arm-unknown-linux-gnueabi** - For QEMU (soft-float)

Located in: `~/x-tools/`

### 2. Bootloader (BBB only)
U-Boot 2025.10 for BeagleBone Black:
- `MLO` (108KB) - First-stage loader
- `u-boot.img` (1.5MB) - Main bootloader
- Boots from SD card, loads kernel and device tree

### 3. Kernel
Linux 6.6 LTS for both platforms:
```bash
cd kernel
./build-bbb.sh   # BeagleBone Black
./build-qemu.sh  # QEMU
```

Output:
- zImage (compressed kernel)
- Device tree blob (.dtb)

### 4. Root Filesystem
Complete userspace with BusyBox:
```bash
cd rootfs
sudo ./setup.sh      # Create filesystems
sudo ./build-bbb.sh  # Build BBB kernel with embedded rootfs
sudo ./build-qemu.sh # Build QEMU kernel
./test-qemu.sh       # Test in emulation
```

Creates:
- `~/rootfs-bbb/` - BeagleBone Black filesystem
- `~/rootfs-qemu/` - QEMU filesystem

Both embedded in kernel images as initramfs.

## Technical Details

### Toolchain
- **ABI**: Hard-float (Cortex-A8) vs Soft-float (QEMU)
- **C Library**: glibc
- **Compiler**: GCC 15.2.0

### Kernel
- **Version**: 6.6 LTS
- **Format**: zImage (compressed)
- **Initramfs**: Built-in (embedded in kernel)
- **BBB Config**: multi_v7_defconfig (comprehensive)
- **QEMU Config**: versatile_defconfig (minimal)

### Root Filesystem
- **Base**: BusyBox (402 Unix utilities, statically linked)
- **Init**: BusyBox init with `/etc/inittab`
- **Startup**: `/etc/init.d/rcS` script
- **Size**: ~16MB
- **Network**: NSS libraries for DNS resolution

## Boot Process

1. ROM → Loads SPL (MLO)
2. SPL → Initializes DDR, loads U-Boot
3. U-Boot → Loads kernel + device tree to RAM
4. Kernel → Unpacks built-in initramfs
5. Init → Mounts filesystems, runs startup scripts
6. Shell → Spawns on console

## Testing

### QEMU (Fast Testing)
```bash
cd rootfs
./test-qemu.sh
# Boots in ~2 seconds
# Ctrl+A then X to exit
```

### BeagleBone Black
Tested on real hardware:
- Boot time: ~4 seconds to shell
- Serial console working (115200 baud)
- All BusyBox commands functional
- Init system working correctly

## Build Times

- Toolchain: ~1 hour (one-time)
- U-Boot: ~10 minutes
- Kernel: ~30 minutes (first), ~5 minutes (incremental)
- Root FS: ~5 minutes

**Total**: ~2 hours from scratch

## Key Concepts

### Cross-Compilation
Building ARM binaries on x86 host, requires proper toolchain prefix and sysroot configuration.

### Device Trees
Hardware description separate from kernel - allows same kernel to support multiple boards.

### Init System
- BusyBox init runs as PID 1
- `/etc/inittab` controls what runs at boot
- `/etc/init.d/rcS` does system initialization

### Initramfs
Root filesystem embedded in kernel image, unpacked to RAM at boot. Simpler than separate ramdisk file.

## What I Learned

- Cross-platform embedded development
- Bootloader configuration and memory layout
- Kernel compilation and configuration
- Root filesystem construction from scratch
- Init system design
- Device tree development
- Build automation with shell scripts

## Documentation

See subdirectories for detailed info:
- `toolchain/README.md` - Toolchain build process
- `bootloader/README.md` - U-Boot setup
- `kernel/README.md` - Kernel compilation
- `rootfs/README.md` - System integration
