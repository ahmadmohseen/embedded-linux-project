# U-Boot Bootloader

U-Boot 2025.10 configured for BeagleBone Black.

## Build Steps

```bash
cd ~/
git clone https://source.denx.de/u-boot/u-boot.git
cd u-boot
git checkout v2025.10

export PATH=~/x-tools/arm-cortex_a8-linux-gnueabihf/bin:$PATH
export CROSS_COMPILE=arm-cortex_a8-linux-gnueabihf-

make am335x_evm_defconfig
make -j4
```

## Output Files

- **MLO** (~108KB) - First stage bootloader (SPL)
- **u-boot.img** (~1.5MB) - Main U-Boot image

## SD Card Setup

```bash
./format-sdcard.sh sdb   # Format SD card

sudo mount /dev/sdb1 /media/ahmad/boot
cp MLO u-boot.img /media/ahmad/boot/
sudo umount /media/ahmad/boot
```

## Hardware Setup

- **Serial Console**: USB-to-TTL on J1 header
- **Baud**: 115200
- **Terminal**: `screen /dev/ttyUSB0 115200`
- **Boot**: Hold S2 button while powering on

## Boot Output
```
U-Boot SPL 2025.10 (Nov 17 2025)
Trying to boot from MMC1

U-Boot 2025.10 (Nov 17 2025)
CPU  : AM335X-GP rev 2.1
Model: TI AM335x BeagleBone Black
DRAM:  512 MiB
```

## Result

✅ U-Boot boots successfully on BeagleBone Black  
✅ Serial console working  
✅ Ready for kernel deployment
