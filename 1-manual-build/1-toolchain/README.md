# Cross-Compilation Toolchains

## What Was Built

Two ARM toolchains were built using crosstool-ng 1.28.0:

### 1. BeagleBone Black Toolchain
- **Toolchain:** arm-cortex_a8-linux-gnueabihf
- **Target:** ARM Cortex-A8 (hard-float ABI)
- **C Library:** glibc
- **Installation:** ~/x-tools/arm-cortex_a8-linux-gnueabihf/

### 2. QEMU ARM Toolchain
- **Toolchain:** arm-unknown-linux-gnueabi
- **Target:** ARM Generic (soft-float ABI)
- **C Library:** glibc
- **Installation:** ~/x-tools/arm-unknown-linux-gnueabi/

## Build Steps

### Setup crosstool-ng (once)

```bash
# 1. Clone and checkout latest stable version
cd ~/
git clone https://github.com/crosstool-ng/crosstool-ng.git
cd crosstool-ng
git checkout crosstool-ng-1.28.0

# 2. Bootstrap and configure
./bootstrap
./configure --prefix=${PWD}
make
make install
```

### Build BeagleBone Black Toolchain

```bash
cd ~/crosstool-ng

# Select target configuration
bin/ct-ng arm-cortex_a8-linux-gnueabi

# Customize (optional)
bin/ct-ng menuconfig
# Disabled: "Render the toolchain read-only" in Paths and misc options

# Build (takes 30-60 minutes)
bin/ct-ng build
```

### Build QEMU Toolchain

```bash
cd ~/crosstool-ng

# Select target configuration
bin/ct-ng arm-unknown-linux-gnueabi

# Customize (optional)
bin/ct-ng menuconfig
# Disabled: "Render the toolchain read-only" in Paths and misc options

# Build (takes 30-60 minutes)
bin/ct-ng build
```

## Dependencies Installed

```bash
sudo apt-get install -y \
    libssl-dev \
    libgnutls28-dev \
    device-tree-compiler \
    swig \
    python3-dev \
    uuid-dev \
    flex \
    bison \
    build-essential \
    bc
```

## Issues Resolved

1. **Missing OpenSSL:** Resolved by installing `libssl-dev`
2. **Missing GnuTLS:** Resolved by installing `libgnutls28-dev`


## Verification

```bash
# Check toolchain
~/x-tools/arm-cortex_a8-linux-gnueabihf/bin/arm-cortex_a8-linux-gnueabihf-gcc --version

# Add to PATH
export PATH=~/x-tools/arm-cortex_a8-linux-gnueabihf/bin:$PATH
```

## Result

✅ Working cross-compilation toolchain ready for U-Boot and kernel builds

