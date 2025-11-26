# Embedded Linux Systems - From Scratch Implementation

A complete implementation of embedded Linux systems for ARM platforms, demonstrating expertise in low-level Linux system development, cross-compilation, bootloader configuration, and root filesystem creation.

## Project Overview

This project implements fully functional embedded Linux systems for two ARM platforms:
- **BeagleBone Black** (TI AM335x ARM Cortex-A8) - Real hardware deployment
- **QEMU ARM Versatile PB** - Emulation and testing environment

## Technical Implementation

### Architecture

```
embedded-linux-project/
├── 1-manual-build/          # Complete manual build system
│   ├── 1-toolchain/         # Cross-compilation toolchains
│   ├── 2-bootloader/        # U-Boot bootloader implementation
│   ├── 3-kernel/            # Linux kernel builds with device trees
│   └── 4-rootfs/            # Root filesystem with init system
├── 2-buildroot/             # Automated build system integration
└── 3-yocto/                 # Yocto Project layer development
```

## Core Components

### 1. Cross-Compilation Toolchains

Built custom ARM toolchains using crosstool-NG:
- **ARM Cortex-A8 hard-float** (`arm-cortex_a8-linux-gnueabihf`) - Optimized for BeagleBone Black
- **ARM generic soft-float** (`arm-unknown-linux-gnueabi`) - QEMU compatible

**Key features:**
- Custom glibc configuration
- Hardware floating-point support
- Optimized for target architecture

### 2. Bootloader - U-Boot

Implemented U-Boot bootloader for BeagleBone Black:
- SPL (Secondary Program Loader) configuration
- Device tree loading
- Memory-mapped boot from SD card
- Serial console configuration

**Deliverables:**
- `MLO` (108KB) - First-stage bootloader
- `u-boot.img` (1.5MB) - Main bootloader

### 3. Linux Kernel 6.6 LTS

Custom kernel builds with device tree support:
- Multi-platform ARM configuration for BeagleBone Black
- Minimal configuration for QEMU (optimized size)
- Device tree compilation and integration
- Built-in initramfs support

**Specifications:**
- BeagleBone Black: 17MB zImage (includes initramfs)
- QEMU: 9.8MB zImage (includes initramfs)

### 4. Root Filesystem

Custom root filesystem implementation:
- **BusyBox** userspace with 402 Unix utilities
- Custom init system with startup scripts
- Filesystem Hierarchy Standard (FHS) compliant
- Optimized for embedded deployment (~16MB)

**Init system features:**
- Automatic filesystem mounting (`proc`, `sysfs`, `devtmpfs`)
- Network loopback configuration
- System hostname configuration
- Shell spawn with proper TTY handling

## Quick Start

### Build Complete System

```bash
# Create root filesystems
cd 1-manual-build/4-rootfs
./setup-rootfs.sh

# Build kernels with embedded initramfs
./build-bbb-kernel.sh      # BeagleBone Black
./build-qemu-kernel.sh     # QEMU

# Test in emulation
./test-qemu.sh
```

### Deploy to Hardware

```bash
# Deploy to SD card
sudo mount /dev/sdb1 /media/ahmad/boot
sudo cp ~/linux-stable/arch/arm/boot/zImage /media/ahmad/boot/
sudo sync
sudo umount /media/ahmad/boot

# Boot on BeagleBone Black
# See 4-rootfs/README.md for U-Boot commands
```

## Technical Skills Demonstrated

### System Design
- Cross-platform embedded system architecture
- Boot sequence optimization
- Memory layout planning
- Init system design

### Low-Level Programming
- Bootloader configuration and deployment
- Kernel configuration and compilation
- Device tree development
- ARM assembly awareness (boot process)

### Build Systems
- crosstool-NG toolchain configuration
- Kernel kbuild system
- Custom build scripts and automation
- Dependency management

### Embedded Linux Expertise
- Root filesystem construction
- BusyBox integration and configuration
- Init system implementation
- Hardware-specific optimizations

## System Specifications

| Component | BeagleBone Black | QEMU ARM |
|-----------|------------------|-----------|
| **CPU** | TI AM335x Cortex-A8 | ARM926EJ-S |
| **Kernel** | Linux 6.6 LTS (17MB) | Linux 6.6 LTS (9.8MB) |
| **Bootloader** | U-Boot 2025.10 | Direct boot |
| **Root FS** | BusyBox (~16MB) | BusyBox (~16MB) |
| **Init** | Custom BusyBox init | Custom BusyBox init |
| **Boot Time** | ~4 seconds to shell | ~2 seconds to shell |

## Build Environment

### Host Requirements
- Linux (Ubuntu/Debian tested)
- ~20GB disk space
- Multi-core CPU (recommended for parallel builds)

### Dependencies
```bash
sudo apt-get install -y \
    build-essential git autoconf automake bison flex \
    libssl-dev libgnutls28-dev device-tree-compiler \
    u-boot-tools qemu-system-arm screen
```

## Documentation

Comprehensive documentation provided:
- `1-toolchain/README.md` - Toolchain build process
- `2-bootloader/README.md` - U-Boot configuration
- `3-kernel/README.md` - Kernel compilation
- `4-rootfs/README.md` - Complete system integration

## Validation

Both systems fully tested and operational:
- ✅ BeagleBone Black boots to interactive shell
- ✅ QEMU emulation runs successfully
- ✅ All BusyBox applets functional
- ✅ Init system properly mounts filesystems
- ✅ Network loopback operational

## Future Enhancements

Planned improvements:
- Buildroot integration for automated builds
- Yocto Project layer development
- Custom application deployment
- NFS root filesystem for development
- Package management system

## Technical References

**Component Versions:**
- crosstool-NG: 1.28.0
- U-Boot: v2025.10
- Linux Kernel: 6.6 LTS
- BusyBox: Latest stable

**Standards & Specifications:**
- Filesystem Hierarchy Standard (FHS)
- Device Tree Specification
- ARM EABI (hard-float/soft-float)

## License

Scripts and configuration in this repository are provided under standard open-source practices.
Component licenses (Linux, U-Boot, BusyBox) remain under their respective terms.
