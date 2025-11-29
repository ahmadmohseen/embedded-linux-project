# Linux Kernel

Linux 6.6 LTS compiled for BeagleBone Black and QEMU ARM.

## BeagleBone Black Kernel

### Build
```bash
cd ~/linux-stable
export PATH=~/x-tools/arm-cortex_a8-linux-gnueabihf/bin:$PATH
export ARCH=arm
export CROSS_COMPILE=arm-cortex_a8-linux-gnueabihf-

make mrproper
make multi_v7_defconfig
make -j10 zImage
make -j10 modules
make dtbs
```

### Output
- **zImage**: `arch/arm/boot/zImage` (~11MB)
- **Device tree**: `arch/arm/boot/dts/ti/omap/am335x-boneblack.dtb` (~69KB)

### Deploy to SD Card
```bash
sudo mount /dev/sdb1 /media/ahmad/boot
sudo cp arch/arm/boot/zImage /media/ahmad/boot/
sudo cp arch/arm/boot/dts/ti/omap/am335x-boneblack.dtb /media/ahmad/boot/
sudo sync && sudo umount /media/ahmad/boot
```

### U-Boot Commands
```
fatload mmc 0:1 0x80200000 zImage
fatload mmc 0:1 0x80f00000 am335x-boneblack.dtb
bootz 0x80200000 - 0x80f00000
```

## QEMU ARM Kernel

### Build
```bash
cd ~/linux-stable-qemu
export PATH=~/x-tools/arm-unknown-linux-gnueabi/bin:$PATH
export ARCH=arm
export CROSS_COMPILE=arm-unknown-linux-gnueabi-

make mrproper
make versatile_defconfig
make -j10 zImage
make -j10 modules
make dtbs
```

### Output
- **zImage**: `arch/arm/boot/zImage` (~3.5MB, smaller than BBB)
- **Device tree**: `arch/arm/boot/dts/arm/versatile-pb.dtb` (~9KB)

### Run in QEMU
```bash
QEMU_AUDIO_DRV=none qemu-system-arm \
  -m 256M -nographic -M versatilepb \
  -kernel ~/linux-stable-qemu/arch/arm/boot/zImage \
  -append "console=ttyAMA0,115200" \
  -dtb ~/linux-stable-qemu/arch/arm/boot/dts/arm/versatile-pb.dtb
```

Exit: `Ctrl+A` then `x`

## Key Points

- **Separate source trees**: Avoids overwriting builds for different targets
- **multi_v7_defconfig**: Full-featured for BBB, supports many ARM SoCs
- **versatile_defconfig**: Minimal for QEMU testing
- **Hard-float vs soft-float**: Different toolchains for optimal performance

## Result

✅ BeagleBone Black kernel compiles successfully  
✅ QEMU ARM kernel compiles successfully  
✅ Both kernels boot with integrated rootfs (see `rootfs/` directory)
