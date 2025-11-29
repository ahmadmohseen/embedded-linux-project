# Embedded Linux Systems

Building complete embedded Linux systems for ARM platforms from scratch, using both manual builds and automated build systems.

## What's This?

This project demonstrates building bootable embedded Linux systems for:
- **BeagleBone Black** (TI AM335x Cortex-A8) - Real hardware
- **QEMU ARM** (Versatile PB) - Emulation/testing

## Project Structure

```
embedded-linux-project/
├── manual/        # Manual builds from scratch
│   ├── toolchain/ # Cross-compilation toolchains
│   ├── bootloader/# U-Boot for BeagleBone Black
│   ├── kernel/    # Linux kernel 6.6 LTS
│   └── rootfs/    # Root filesystem with BusyBox
├── buildroot/     # Buildroot automated builds
└── yocto/         # Yocto Project builds
```

## Quick Start

### Manual Build
```bash
cd manual/rootfs
sudo ./setup.sh         # Create root filesystem
sudo ./build-bbb.sh     # Build for BeagleBone Black
sudo ./build-qemu.sh    # Build for QEMU
./test-qemu.sh          # Test in emulation
```

### Buildroot
```bash
cd buildroot
./build.sh qemu  # or ./build.sh bbb
```

## System Specs

| Component | BeagleBone Black | QEMU ARM |
|-----------|-----------------|-----------|
| **CPU** | TI AM335x Cortex-A8 | ARM926EJ-S |
| **Kernel** | Linux 6.6 LTS (17MB) | Linux 6.6 LTS (9.8MB) |
| **Bootloader** | U-Boot 2025.10 | Direct boot |
| **Root FS** | BusyBox (~16MB) | BusyBox (~16MB) |
| **Boot Time** | ~4 sec | ~2 sec |

## What I Built

### 1. Manual Implementation
Built everything from first principles:
- Cross-compilation toolchains using crosstool-NG
  - Hard-float for BeagleBone Black (`arm-cortex_a8-linux-gnueabihf`)
  - Soft-float for QEMU (`arm-unknown-linux-gnueabi`)
- U-Boot bootloader configuration and deployment
- Custom kernel configuration with device tree support
- Root filesystem with BusyBox (402 Unix utilities)
- Custom init system with startup scripts

### 2. Buildroot
Automated build system demonstrating professional workflows:
- One-command complete system builds
- Package dependency management
- Reproducible builds with configuration files
- Successfully built and tested for QEMU (network verified)

### 3. Yocto Project
Enterprise-level build system with layer architecture:
- BitBake-based build automation
- Layer and recipe development
- BSP integration for different hardware platforms

## Technical Skills

This project demonstrates:
- ARM cross-compilation and toolchain configuration
- Bootloader (U-Boot) setup and deployment
- Linux kernel customization and device tree development
- Root filesystem construction and init system design
- Build system expertise (manual, Buildroot, Yocto)
- Hardware bring-up on real embedded hardware
- Network configuration and testing

## Build Environment

**Host**: Ubuntu 20.04 in VirtualBox
**Disk**: ~20GB for manual builds, ~50GB for Buildroot
**Build times**: 
- Manual: ~2 hours from scratch
- Buildroot: ~30-60 minutes
- Yocto: ~2-4 hours (first build)

## Status

✅ Manual builds - Complete and tested on hardware  
✅ Buildroot QEMU - Complete, network operational  
✅ Buildroot BBB - Complete, ready to deploy  
✅ Yocto - Documentation and automation complete

## Testing

Both systems boot successfully:
- Shell access working
- Init system mounts filesystems correctly
- BusyBox applets functional
- Network loopback operational
- BeagleBone Black boots from SD card in ~4 seconds

## Component Versions

- crosstool-NG: 1.28.0
- U-Boot: v2025.10
- Linux Kernel: 6.6 LTS
- BusyBox: Latest stable
- Buildroot: 2024.02.9
- Yocto: Kirkstone (4.0 LTS)
