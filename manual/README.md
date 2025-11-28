# Manual Build Implementation

Complete embedded Linux systems built from first principles, demonstrating deep understanding of embedded Linux architecture and build processes.

## Overview

This implementation builds all components manually, providing complete control and understanding of:
1. Cross-compilation toolchains
2. Bootloader configuration and deployment
3. Linux kernel compilation with device trees
4. Root filesystem construction and init systems

## Build Pipeline

### 1. Toolchain Construction (`toolchain/`)

Custom ARM toolchains built using crosstool-NG:

**Deliverables:**
- `~/x-tools/arm-cortex_a8-linux-gnueabihf/` - Hard-float toolchain for BeagleBone Black
- `~/x-tools/arm-unknown-linux-gnueabi/` - Soft-float toolchain for QEMU

**Technical details:**
- Custom glibc configuration for target architecture
- Optimized compiler flags for ARM Cortex-A8
- Complete sysroot with development headers

### 2. Bootloader Implementation (`bootloader/`)

U-Boot configuration for BeagleBone Black:

**Deliverables:**
- `MLO` - SPL (Secondary Program Loader)
- `u-boot.img` - Main U-Boot binary
- Formatted SD card ready for deployment

**Features:**
- FAT32 boot partition support
- Device tree loading capability
- Memory-mapped register access
- Serial console at 115200 baud

### 3. Kernel Compilation (`kernel/`)

Linux 6.6 LTS builds for both platforms:

```bash
cd kernel
./build-bbb.sh      # BeagleBone Black kernel
./build-qemu.sh     # QEMU kernel
```

**Deliverables:**
- Compressed kernel images (zImage)
- Compiled device tree blobs (.dtb)

**Configuration:**
- Multi-v7 defconfig for BeagleBone Black (comprehensive driver support)
- Versatile defconfig for QEMU (minimal, optimized for emulation)

### 4. Root Filesystem & System Integration (`rootfs/`)

Complete userspace implementation:

```bash
cd rootfs
sudo ./setup.sh          # Create base filesystems
sudo ./build-bbb.sh      # Build kernel with embedded initramfs
sudo ./build-qemu.sh     # Build QEMU kernel
./test-qemu.sh           # Validate in emulation
```

**Deliverables:**
- `/home/ahmad/rootfs-bbb/` - BeagleBone Black root filesystem
- `/home/ahmad/rootfs-qemu/` - QEMU root filesystem
- Bootable kernel images with embedded initramfs

## Technical Implementation

### Toolchain
- **ABI:** Hard-float for Cortex-A8, soft-float for QEMU
- **C Library:** glibc (full-featured)
- **Compiler:** GCC 15.2.0
- **Linker:** GNU ld 2.45

### Bootloader
- **Architecture:** Two-stage boot (SPL → U-Boot)
- **Storage:** SD card (MMC)
- **Load addresses:** Optimized for AM335x memory map
- **Console:** UART0 (115200n8)

### Kernel
- **Version:** 6.6 LTS (long-term support)
- **Format:** zImage (compressed)
- **Device Trees:** Compiled FDT blobs
- **Initramfs:** Built-in (embedded in kernel image)

### Root Filesystem
- **Base:** BusyBox (statically linked)
- **Utilities:** 402 Unix commands
- **Init:** BusyBox init with custom scripts
- **Network:** NSS libraries for name resolution
- **Size:** ~16MB (optimized for embedded)

## Boot Process

1. **ROM Boot** → Loads SPL (MLO)
2. **SPL** → Initializes DDR, loads U-Boot
3. **U-Boot** → Loads kernel and device tree to RAM
4. **Kernel** → Unpacks built-in initramfs to RAM
5. **Init** → Mounts filesystems, runs startup scripts
6. **Shell** → Spawns on console

## Testing

### QEMU Testing

Fast iteration with emulation:
```bash
cd rootfs
./test-qemu.sh
# System boots in ~2 seconds
# Full shell access for testing
```

### Hardware Deployment

Tested and operational on BeagleBone Black:
- Boot time: ~4 seconds to shell
- Serial console fully functional
- All BusyBox commands working
- Init system properly configured
- Network loopback operational

## Build Time Estimates

- **Toolchain:** ~1 hour (first build)
- **U-Boot:** ~10 minutes
- **Kernel:** ~30 minutes (first build, ~5min incremental)
- **Root FS:** ~5 minutes

**Total:** ~2 hours for complete system from scratch

## Key Concepts

### Cross-Compilation
- Target vs. host architecture awareness
- Sysroot and library search paths
- Toolchain prefix usage
- ABI compatibility

### Device Trees
- Hardware description separation from kernel
- Runtime hardware configuration
- Platform-specific customization
- Bootloader-kernel communication

### Init System
- `/sbin/init` as PID 1
- `/etc/inittab` configuration
- `/etc/init.d/rcS` startup script
- Filesystem mounting and system setup

### Network Integration
- NSS (Name Service Switch) libraries
- Network configuration framework
- Interface management (ifup/ifdown)
- DHCP client support (udhcpc)

## Technical Skills Demonstrated

- ✅ Cross-platform embedded development
- ✅ Low-level system programming
- ✅ Bootloader configuration
- ✅ Kernel compilation and configuration
- ✅ Root filesystem construction
- ✅ Init system design
- ✅ Device tree development
- ✅ Network configuration
- ✅ Build system expertise
