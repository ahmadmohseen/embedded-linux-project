# U-Boot Bootloader

## What Was Built

- **Bootloader:** U-Boot 2025.10
- **Target:** BeagleBone Black (TI AM335x)
- **Configuration:** am335x_evm_defconfig
- **Status:** ✅ Successfully booting on hardware

## Build Steps

```bash
# 1. Clone U-Boot
cd ~/
git clone https://source.denx.de/u-boot/u-boot.git
cd u-boot
git checkout v2025.10

# 2. Set up cross-compilation
export PATH=~/x-tools/arm-cortex_a8-linux-gnueabihf/bin:$PATH
export CROSS_COMPILE=arm-cortex_a8-linux-gnueabihf-

# 3. Configure for BeagleBone Black
make am335x_evm_defconfig

# 4. Build (takes 5-10 minutes)
make -j4
```

## Dependencies (Already Installed for Toolchain)

```bash
sudo apt-get install -y libssl-dev libgnutls28-dev device-tree-compiler
```

## Output Files

- **MLO** (~108KB) - First stage bootloader (SPL)
- **u-boot.img** (~1.5MB) - Main U-Boot image

## SD Card Preparation

```bash
# Format 128GB SD card (modified script for large cards)
./format-sdcard.sh sdb

# Mount partitions
sudo mount /dev/sdb1 /media/ahmad/boot

# Copy bootloader files
cp MLO u-boot.img /media/ahmad/boot/

# Unmount
sudo umount /media/ahmad/boot
```

## Hardware Setup

- **Serial Console:** USB-to-TTL adapter on J1 header
- **Baud Rate:** 115200
- **Terminal:** `screen /dev/ttyUSB0 115200`
- **Power:** USB cable (micro-USB)
- **Boot:** Hold S2 button while powering on to boot from SD card

## Boot Output

```
U-Boot SPL 2025.10 (Nov 17 2025 - 11:19:34 +0000)
Trying to boot from MMC1

U-Boot 2025.10 (Nov 17 2025 - 11:19:34 +0000)

CPU  : AM335X-GP rev 2.1
Model: TI AM335x BeagleBone Black
DRAM:  512 MiB
```

## Modifications Made

### format-sdcard.sh
- **Original limit:** 32GB (64,000,000 sectors)
- **New limit:** 256GB (500,000,000 sectors)
- **Reason:** Support for modern large SD cards

## Result

✅ U-Boot successfully boots on BeagleBone Black
✅ Serial console working at 115200 baud
✅ Ready for kernel deployment

