# Cross-Compilation Toolchains

Built two ARM toolchains using crosstool-ng 1.28.0:

## Toolchains

### BeagleBone Black
- **Toolchain**: arm-cortex_a8-linux-gnueabihf
- **Target**: ARM Cortex-A8 (hard-float)
- **C Library**: glibc
- **Location**: ~/x-tools/arm-cortex_a8-linux-gnueabihf/

### QEMU ARM
- **Toolchain**: arm-unknown-linux-gnueabi
- **Target**: ARM Generic (soft-float)
- **C Library**: glibc
- **Location**: ~/x-tools/arm-unknown-linux-gnueabi/

## Build Steps

### One-time Setup
```bash
cd ~/
git clone https://github.com/crosstool-ng/crosstool-ng.git
cd crosstool-ng
git checkout crosstool-ng-1.28.0

./bootstrap
./configure --prefix=${PWD}
make && make install
```

### Build Each Toolchain
```bash
cd ~/crosstool-ng

# For BeagleBone Black
bin/ct-ng arm-cortex_a8-linux-gnueabi
bin/ct-ng menuconfig  # Disabled "Render read-only"
bin/ct-ng build       # Takes 30-60 minutes

# For QEMU
bin/ct-ng arm-unknown-linux-gnueabi
bin/ct-ng menuconfig  # Disabled "Render read-only"
bin/ct-ng build       # Takes 30-60 minutes
```

## Dependencies
```bash
sudo apt-get install -y libssl-dev libgnutls28-dev device-tree-compiler \
    swig python3-dev uuid-dev flex bison build-essential bc
```

## Usage
```bash
export PATH=~/x-tools/arm-cortex_a8-linux-gnueabihf/bin:$PATH
arm-cortex_a8-linux-gnueabihf-gcc --version
```

## Result

✅ Two working cross-compilation toolchains ready for U-Boot and kernel builds
