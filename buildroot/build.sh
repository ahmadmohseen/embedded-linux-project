#!/bin/bash
#
# Build Buildroot systems for QEMU or BeagleBone Black
#
# Usage:
#   ./build.sh qemu    - Build for QEMU ARM Versatile PB
#   ./build.sh bbb     - Build for BeagleBone Black
#   ./build.sh all     - Build both systems
#

set -e

BUILDROOT_DIR="/home/ahmad/buildroot"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo "========================================="
    echo -e "${BLUE}$1${NC}"
    echo "========================================="
    echo ""
}

build_qemu() {
    print_header "Building Buildroot for QEMU ARM Versatile PB"
    
    cd "$BUILDROOT_DIR"
    
    # Configure if not already done
    if [ ! -f "output/.config" ]; then
        echo "Configuring QEMU build..."
        make qemu_arm_versatile_defconfig
    fi
    
    echo "Building with $(nproc) parallel jobs..."
    echo "Estimated time: 30-60 minutes"
    echo ""
    
    make -j$(nproc)
    
    echo ""
    print_header "✓ QEMU Build Complete!"
    echo "Images location: $BUILDROOT_DIR/output/images/"
    ls -lh "$BUILDROOT_DIR/output/images/"
    echo ""
    echo "To run: cd $BUILDROOT_DIR/output/images && ./start-qemu.sh --serial-only"
    echo ""
}

build_bbb() {
    print_header "Building Buildroot for BeagleBone Black"
    
    cd "$BUILDROOT_DIR"
    
    # Configure if not already done
    if [ ! -f "output-bbb/.config" ]; then
        echo "Configuring BBB build..."
        make O=output-bbb beaglebone_defconfig
    fi
    
    echo "Building with $(nproc) parallel jobs..."
    echo "Estimated time: 30-60 minutes"
    echo ""
    
    make O=output-bbb -j$(nproc)
    
    echo ""
    print_header "✓ BBB Build Complete!"
    echo "Images location: $BUILDROOT_DIR/output-bbb/images/"
    ls -lh "$BUILDROOT_DIR/output-bbb/images/"
    echo ""
    echo "To deploy:"
    echo "  1. cd /home/ahmad/embedded-linux-project/manual/bootloader"
    echo "  2. sudo ./format-sdcard.sh /dev/sdX"
    echo "  3. Follow deployment steps in buildroot/README.md"
    echo ""
}

show_usage() {
    echo "Usage: $0 {qemu|bbb|all}"
    echo ""
    echo "Commands:"
    echo "  qemu  - Build for QEMU ARM Versatile PB"
    echo "  bbb   - Build for BeagleBone Black"
    echo "  all   - Build both systems"
    echo ""
    echo "Example:"
    echo "  $0 qemu"
    echo ""
}

# Check if buildroot exists
if [ ! -d "$BUILDROOT_DIR" ]; then
    echo "ERROR: Buildroot not found at $BUILDROOT_DIR"
    echo ""
    echo "Please clone it first:"
    echo "  git clone https://github.com/buildroot/buildroot.git $BUILDROOT_DIR"
    echo "  cd $BUILDROOT_DIR"
    echo "  git checkout 2024.02.9"
    exit 1
fi

# Parse command
case "${1:-}" in
    qemu)
        build_qemu
        ;;
    bbb)
        build_bbb
        ;;
    all)
        build_qemu
        build_bbb
        ;;
    *)
        show_usage
        exit 1
        ;;
esac

