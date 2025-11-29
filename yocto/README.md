# Yocto Project Build System

Enterprise-level build system using layers and BitBake.

## What is Yocto?

Layer-based build system for creating custom Linux distributions:
- **Poky**: Reference distribution
- **BitBake**: Build engine (processes recipes)
- **Layers**: Modular recipe collections
- **Recipes**: Build instructions for packages

**Version**: Kirkstone (4.0 LTS)

## Prerequisites

### Packages
```bash
sudo apt-get install -y gawk wget git diffstat unzip texinfo gcc build-essential \
    chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils \
    iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev pylint3 \
    xterm python3-subunit mesa-common-dev zstd liblz4-tool
```

### Disk Space
- **Minimum**: 50 GB
- **Recommended**: 100+ GB

### Source Setup
```bash
cd /home/ahmad
git clone -b kirkstone git://git.yoctoproject.org/poky.git
git clone -b kirkstone https://github.com/openembedded/meta-openembedded.git
```

## Quick Start

```bash
# Build for QEMU
./build.sh qemu

# Build for BeagleBone Black
./build.sh bbb

# Clean builds
./build.sh clean qemu
```

## Manual Build

### 1. Initialize
```bash
cd /home/ahmad
source poky/oe-init-build-env build-qemuarm  # or build-bbb
```

### 2. Configure

Edit `conf/local.conf`:
```bash
MACHINE = "qemuarm"  # or "beaglebone-yocto"
BB_NUMBER_THREADS = "4"
PARALLEL_MAKE = "-j 4"
INHERIT += "rm_work"  # Save disk space
```

Edit `conf/bblayers.conf` to add meta-openembedded layers.

### 3. Build
```bash
bitbake core-image-minimal
```

Build time: 2-4 hours (first), 30-60 minutes (subsequent)

## Testing

### QEMU
```bash
cd /home/ahmad/build-qemuarm/tmp/deploy/images/qemuarm
runqemu qemuarm nographic
```

Test network:
```bash
ifconfig
ping -c 3 google.com
```

Exit: `Ctrl+A` then `X`

## Deployment to BeagleBone Black

### Output Files
Location: `/home/ahmad/build-bbb/tmp/deploy/images/beaglebone-yocto/`
- `MLO` - First-stage bootloader
- `u-boot.img` - U-Boot
- `zImage` - Kernel
- `zImage-am335x-boneblack.dtb` - Device tree
- `core-image-minimal-beaglebone-yocto.tar.bz2` - Rootfs

### SD Card Setup

1. **Format** (2 partitions: 64MB FAT32 + rest ext4)
2. **Copy boot files**:
```bash
sudo mount /dev/sdX1 /mnt
sudo cp MLO u-boot.img zImage *.dtb /mnt
sudo umount /mnt
```

3. **Extract rootfs**:
```bash
sudo mount /dev/sdX2 /mnt
sudo tar -xjf core-image-minimal-beaglebone-yocto.tar.bz2 -C /mnt
sudo umount /mnt
```

## Customization

### Add Packages
Edit `conf/local.conf`:
```bash
IMAGE_INSTALL:append = " nano vim openssh"
```

### Create Custom Layer
```bash
bitbake-layers create-layer meta-custom
bitbake-layers add-layer meta-custom
```

## Troubleshooting

**Out of disk space**:
```bash
echo 'INHERIT += "rm_work"' >> conf/local.conf
bitbake -c clean <package>
```

**Build failures**:
```bash
bitbake -c cleansstate <recipe>
bitbake -f <recipe>  # Force rebuild
```

## Build Directory Structure
```
build-qemuarm/  or  build-bbb/
├── conf/               # Configuration
├── tmp/deploy/images/  # Final images
├── tmp/work/           # Build artifacts
└── downloads/          # Source packages
```

## Resources

- [Yocto Documentation](https://docs.yoctoproject.org/)
- [BitBake Manual](https://docs.yoctoproject.org/bitbake/)
- [Yocto Reference](https://docs.yoctoproject.org/ref-manual/)

## Status

✅ Documentation complete  
✅ Build automation script ready  
⚠️ Requires significant disk space (~50GB+) - not built due to VM limitations
