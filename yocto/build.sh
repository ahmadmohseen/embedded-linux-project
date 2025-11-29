#!/bin/bash
# Yocto Project build script for QEMU ARM and BeagleBone Black
# This script simplifies the Yocto build process by automating environment setup and configuration

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
POKY_DIR="/home/ahmad/poky"
META_OE_DIR="/home/ahmad/meta-openembedded"
BUILD_DIR_QEMU="/home/ahmad/build-qemuarm"
BUILD_DIR_BBB="/home/ahmad/build-bbb"
NPROC=$(nproc)

# Usage information
usage() {
    echo -e "${BLUE}Yocto Build Script${NC}"
    echo
    echo "Usage: $0 <target> [options]"
    echo
    echo "Targets:"
    echo "  qemu       - Build for QEMU ARM (qemuarm)"
    echo "  bbb        - Build for BeagleBone Black (beaglebone-yocto)"
    echo "  clean      - Clean build directory (requires target: qemu or bbb)"
    echo
    echo "Examples:"
    echo "  $0 qemu              # Build minimal image for QEMU"
    echo "  $0 bbb               # Build minimal image for BeagleBone Black"
    echo "  $0 clean qemu        # Clean QEMU build directory"
    echo
    exit 1
}

# Check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    # Check if Poky exists
    if [ ! -d "$POKY_DIR" ]; then
        echo -e "${RED}Error: Poky directory not found at $POKY_DIR${NC}"
        echo "Please clone Poky first:"
        echo "  cd /home/ahmad"
        echo "  git clone -b kirkstone git://git.yoctoproject.org/poky.git"
        exit 1
    fi
    
    # Check if meta-openembedded exists
    if [ ! -d "$META_OE_DIR" ]; then
        echo -e "${RED}Error: meta-openembedded not found at $META_OE_DIR${NC}"
        echo "Please clone meta-openembedded first:"
        echo "  cd /home/ahmad"
        echo "  git clone -b kirkstone https://github.com/openembedded/meta-openembedded.git"
        exit 1
    fi
    
    # Check disk space (require at least 40GB free)
    FREE_SPACE=$(df -BG /home/ahmad | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$FREE_SPACE" -lt 40 ]; then
        echo -e "${YELLOW}Warning: Low disk space. Available: ${FREE_SPACE}GB, Recommended: 50GB+${NC}"
        echo -e "${YELLOW}Yocto builds require significant disk space.${NC}"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    echo -e "${GREEN}✓ Prerequisites OK${NC}"
    echo
}

# Configure build for QEMU
configure_qemu() {
    local BUILD_DIR="$BUILD_DIR_QEMU"
    local MACHINE="qemuarm"
    
    echo -e "${BLUE}Configuring build for QEMU ARM...${NC}"
    
    # Initialize build environment
    cd /home/ahmad
    source "$POKY_DIR/oe-init-build-env" "$BUILD_DIR" > /dev/null
    
    # Configure local.conf
    if ! grep -q "MACHINE.*qemuarm" conf/local.conf; then
        echo -e "${YELLOW}Updating local.conf for QEMU ARM...${NC}"
        
        # Set machine
        sed -i 's/^MACHINE.*$/MACHINE = "qemuarm"/' conf/local.conf
        
        # Optimize build performance
        cat >> conf/local.conf << EOF

# Build optimization
BB_NUMBER_THREADS = "$NPROC"
PARALLEL_MAKE = "-j $NPROC"

# Reduce disk usage by removing work files after build
INHERIT += "rm_work"
RM_WORK_EXCLUDE += "core-image-minimal"

# Enable networking in QEMU
IMAGE_INSTALL:append = " dropbear"
EOF
    fi
    
    # Configure bblayers.conf
    if ! grep -q "meta-openembedded" conf/bblayers.conf; then
        echo -e "${YELLOW}Adding meta-openembedded layers...${NC}"
        
        cat > conf/bblayers.conf << EOF
# POKY_BBLAYERS_CONF_VERSION is increased each time build/conf/bblayers.conf
# changes incompatibly
POKY_BBLAYERS_CONF_VERSION = "2"

BBPATH = "\${TOPDIR}"
BBFILES ?= ""

BBLAYERS ?= " \\
  $POKY_DIR/meta \\
  $POKY_DIR/meta-poky \\
  $POKY_DIR/meta-yocto-bsp \\
  $META_OE_DIR/meta-oe \\
  $META_OE_DIR/meta-python \\
  $META_OE_DIR/meta-networking \\
  "
EOF
    fi
    
    echo -e "${GREEN}✓ QEMU configuration complete${NC}"
    echo
}

# Configure build for BeagleBone Black
configure_bbb() {
    local BUILD_DIR="$BUILD_DIR_BBB"
    local MACHINE="beaglebone-yocto"
    
    echo -e "${BLUE}Configuring build for BeagleBone Black...${NC}"
    
    # Initialize build environment
    cd /home/ahmad
    source "$POKY_DIR/oe-init-build-env" "$BUILD_DIR" > /dev/null
    
    # Configure local.conf
    if ! grep -q "MACHINE.*beaglebone" conf/local.conf; then
        echo -e "${YELLOW}Updating local.conf for BeagleBone Black...${NC}"
        
        # Set machine
        sed -i 's/^MACHINE.*$/MACHINE = "beaglebone-yocto"/' conf/local.conf
        
        # Optimize build performance
        cat >> conf/local.conf << EOF

# Build optimization
BB_NUMBER_THREADS = "$NPROC"
PARALLEL_MAKE = "-j $NPROC"

# Reduce disk usage by removing work files after build
INHERIT += "rm_work"
RM_WORK_EXCLUDE += "core-image-minimal"

# Enable networking and SSH
IMAGE_INSTALL:append = " dropbear"
EOF
    fi
    
    # Configure bblayers.conf
    if ! grep -q "meta-openembedded" conf/bblayers.conf; then
        echo -e "${YELLOW}Adding meta-openembedded layers...${NC}"
        
        cat > conf/bblayers.conf << EOF
# POKY_BBLAYERS_CONF_VERSION is increased each time build/conf/bblayers.conf
# changes incompatibly
POKY_BBLAYERS_CONF_VERSION = "2"

BBPATH = "\${TOPDIR}"
BBFILES ?= ""

BBLAYERS ?= " \\
  $POKY_DIR/meta \\
  $POKY_DIR/meta-poky \\
  $POKY_DIR/meta-yocto-bsp \\
  $META_OE_DIR/meta-oe \\
  $META_OE_DIR/meta-python \\
  $META_OE_DIR/meta-networking \\
  "
EOF
    fi
    
    echo -e "${GREEN}✓ BeagleBone Black configuration complete${NC}"
    echo
}

# Build image
build_image() {
    local TARGET=$1
    local BUILD_DIR=$2
    
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}Building Yocto image for $TARGET${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${YELLOW}This will take 2-4 hours for first build...${NC}"
    echo
    
    # Initialize build environment (must be done from /home/ahmad)
    cd /home/ahmad
    set +e  # Temporarily disable exit on error for sourcing
    source "$POKY_DIR/oe-init-build-env" "$BUILD_DIR" > /dev/null
    set -e  # Re-enable exit on error
    
    # Build core-image-minimal
    echo -e "${YELLOW}Starting BitBake...${NC}"
    bitbake core-image-minimal
    
    echo
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}✓ Build complete!${NC}"
    echo -e "${GREEN}=========================================${NC}"
    echo
    
    # Show output files
    if [ "$TARGET" = "QEMU" ]; then
        echo -e "${BLUE}Output files:${NC}"
        echo "  Location: $BUILD_DIR/tmp/deploy/images/qemuarm/"
        echo
        echo -e "${BLUE}Test with QEMU:${NC}"
        echo "  cd $BUILD_DIR/tmp/deploy/images/qemuarm"
        echo "  runqemu qemuarm nographic"
        echo "  (Press Ctrl+A, then X to exit)"
    else
        echo -e "${BLUE}Output files:${NC}"
        echo "  Location: $BUILD_DIR/tmp/deploy/images/beaglebone-yocto/"
        echo "  - MLO (first-stage bootloader)"
        echo "  - u-boot.img (U-Boot)"
        echo "  - zImage (kernel)"
        echo "  - *.dtb (device tree)"
        echo "  - core-image-minimal-beaglebone-yocto.tar.bz2 (rootfs)"
        echo
        echo -e "${BLUE}See README.md for SD card deployment instructions${NC}"
    fi
}

# Clean build directory
clean_build() {
    local TARGET=$1
    local BUILD_DIR=$2
    
    echo -e "${YELLOW}Cleaning $TARGET build directory...${NC}"
    
    if [ -d "$BUILD_DIR" ]; then
        echo -e "${RED}Warning: This will delete all build artifacts in $BUILD_DIR${NC}"
        read -p "Continue? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$BUILD_DIR"
            echo -e "${GREEN}✓ Build directory cleaned${NC}"
        else
            echo "Cancelled"
        fi
    else
        echo -e "${YELLOW}Build directory does not exist: $BUILD_DIR${NC}"
    fi
}

# Main script logic
main() {
    if [ $# -lt 1 ]; then
        usage
    fi
    
    COMMAND=$1
    
    case "$COMMAND" in
        qemu)
            check_prerequisites
            configure_qemu
            build_image "QEMU" "$BUILD_DIR_QEMU"
            ;;
        bbb)
            check_prerequisites
            configure_bbb
            build_image "BeagleBone Black" "$BUILD_DIR_BBB"
            ;;
        clean)
            if [ $# -lt 2 ]; then
                echo -e "${RED}Error: clean command requires target (qemu or bbb)${NC}"
                usage
            fi
            
            TARGET=$2
            case "$TARGET" in
                qemu)
                    clean_build "QEMU" "$BUILD_DIR_QEMU"
                    ;;
                bbb)
                    clean_build "BeagleBone Black" "$BUILD_DIR_BBB"
                    ;;
                *)
                    echo -e "${RED}Error: Invalid target '$TARGET'${NC}"
                    usage
                    ;;
            esac
            ;;
        *)
            echo -e "${RED}Error: Invalid command '$COMMAND'${NC}"
            usage
            ;;
    esac
}

main "$@"

