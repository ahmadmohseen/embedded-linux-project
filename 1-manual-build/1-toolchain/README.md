# Cross-Compilation Toolchain

## What Was Built

- **Toolchain:** arm-cortex_a8-linux-gnueabihf
- **Tool:** crosstool-ng 1.28.0
- **Target:** ARM Cortex-A8 (BeagleBone Black)
- **C Library:** glibc
- **Installation:** ~/x-tools/arm-cortex_a8-linux-gnueabihf/

## Build Steps

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

# 3. Select target configuration
bin/ct-ng arm-cortex_a8-linux-gnueabi

# 4. Customize (optional)
bin/ct-ng menuconfig
# Disabled: "Render the toolchain read-only" in Paths and misc options

# 5. Build (takes 30-60 minutes)
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

