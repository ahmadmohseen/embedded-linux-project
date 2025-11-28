#!/bin/bash
# Script to set up root filesystems for BeagleBone Black and QEMU

set -e

echo "========================================="
echo "Root Filesystem Setup Script"
echo "========================================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "WARNING: Running as root. Device nodes will be created."
    CREATE_DEVICES=true
else 
    echo "Running as regular user. Device nodes will be skipped (requires root)."
    CREATE_DEVICES=false
fi

# Paths to toolchains (use absolute paths to work with sudo)
ARM_CORTEX_A8_TOOLCHAIN=/home/ahmad/x-tools/arm-cortex_a8-linux-gnueabihf
ARM_QEMU_TOOLCHAIN=/home/ahmad/x-tools/arm-unknown-linux-gnueabi
BUSYBOX_SRC=/home/ahmad/busybox

# Staging directories
ROOTFS_BBB=/home/ahmad/rootfs-bbb
ROOTFS_QEMU=/home/ahmad/rootfs-qemu

# Function to create directory structure
create_directory_structure() {
    local ROOTFS=$1
    echo "Creating directory structure in $ROOTFS..."
    
    # Create root directory first
    mkdir -p $ROOTFS
    cd $ROOTFS
    
    # Standard Linux FHS directories
    mkdir -p dev
    mkdir -p etc/init.d
    mkdir -p etc/network/if-pre-up.d
    mkdir -p etc/network/if-up.d
    mkdir -p lib
    mkdir -p proc
    mkdir -p sys
    mkdir -p tmp
    mkdir -p var/log
    mkdir -p var/run
    mkdir -p root
    mkdir -p home
    mkdir -p mnt
    mkdir -p opt
    mkdir -p media
    mkdir -p usr/share/udhcpc
    
    echo "  ✓ Directory structure created"
}

# Function to install BusyBox and create symlinks
install_busybox() {
    local ROOTFS=$1
    local TOOLCHAIN=$2
    echo "Installing BusyBox in $ROOTFS..."
    
    # Ensure bin directory exists
    mkdir -p $ROOTFS/bin
    
    # Copy BusyBox binary
    cp $BUSYBOX_SRC/busybox $ROOTFS/bin/busybox
    chmod +x $ROOTFS/bin/busybox
    
    # Create symlinks for all BusyBox applets using busybox.links
    if [ -f "$BUSYBOX_SRC/busybox.links" ]; then
        while IFS= read -r link; do
            # Extract directory and applet name
            dir=$(dirname "$link")
            applet=$(basename "$link")
            
            # Create target directory
            mkdir -p "$ROOTFS$dir"
            
            # Calculate relative path to busybox
            case "$dir" in
                /bin)
                    ln -sf busybox "$ROOTFS$dir/$applet"
                    ;;
                /sbin)
                    ln -sf ../bin/busybox "$ROOTFS$dir/$applet"
                    ;;
                /usr/bin)
                    ln -sf ../../bin/busybox "$ROOTFS$dir/$applet"
                    ;;
                /usr/sbin)
                    ln -sf ../../bin/busybox "$ROOTFS$dir/$applet"
                    ;;
            esac
        done < "$BUSYBOX_SRC/busybox.links"
        
        # Ensure linuxrc symlink exists
        ln -sf bin/busybox "$ROOTFS/linuxrc"
        
        echo "  ✓ BusyBox installed with $(wc -l < $BUSYBOX_SRC/busybox.links) applets"
    else
        echo "  ✗ Error: $BUSYBOX_SRC/busybox.links not found"
        return 1
    fi
}

# Function to install libraries
install_libraries() {
    local ROOTFS=$1
    local TOOLCHAIN=$2
    echo "Installing libraries from $TOOLCHAIN..."
    
    if [ ! -d "$TOOLCHAIN" ]; then
        echo "  ⚠ Toolchain not found at $TOOLCHAIN"
        return
    fi
    
    # Find sysroot
    SYSROOT=$(find $TOOLCHAIN -name "libc.so.6" | sed 's|/lib/libc.so.6||' | head -1)
    
    if [ -z "$SYSROOT" ]; then
        echo "  ⚠ Sysroot not found in toolchain"
        return
    fi
    
    echo "  Using sysroot: $SYSROOT"
    
    # Check if busybox needs libraries (statically linked busybox doesn't need them)
    if file $ROOTFS/bin/busybox | grep -q "statically linked"; then
        echo "  ✓ BusyBox is statically linked, minimal libraries needed"
        # Still copy basic libraries for potential future use
        mkdir -p $ROOTFS/lib
        
        # Copy essential libraries
        if [ -f "$SYSROOT/lib/libc.so.6" ]; then
            cp -a $SYSROOT/lib/libc.so.6 $ROOTFS/lib/
            cp -a $SYSROOT/lib/libc-*.so $ROOTFS/lib/ 2>/dev/null || true
        fi
        
        # Copy ld-linux (dynamic linker)
        cp -a $SYSROOT/lib/ld-*.so* $ROOTFS/lib/ 2>/dev/null || true
        cp -a $SYSROOT/lib/ld-linux*.so* $ROOTFS/lib/ 2>/dev/null || true
        
        # Copy libm (math library)
        if [ -f "$SYSROOT/lib/libm.so.6" ]; then
            cp -a $SYSROOT/lib/libm.so.6 $ROOTFS/lib/
            cp -a $SYSROOT/lib/libm-*.so $ROOTFS/lib/ 2>/dev/null || true
        fi
        
        # Copy NSS (Name Service Switch) libraries for network name resolution
        echo "  → Copying NSS libraries..."
        cp -a $SYSROOT/lib/libnss_files* $ROOTFS/lib/ 2>/dev/null || true
        cp -a $SYSROOT/lib/libnss_dns* $ROOTFS/lib/ 2>/dev/null || true
        cp -a $SYSROOT/lib/libresolv* $ROOTFS/lib/ 2>/dev/null || true
    else
        echo "  ℹ BusyBox is dynamically linked, copying all required libraries"
        # Use ldd to find required libraries (would need qemu-arm-static for cross-arch ldd)
        mkdir -p $ROOTFS/lib
        cp -a $SYSROOT/lib/*.so* $ROOTFS/lib/ 2>/dev/null || true
    fi
    
    echo "  ✓ Libraries installed"
}

# Function to create device nodes (requires root)
create_device_nodes() {
    local ROOTFS=$1
    echo "Creating device nodes in $ROOTFS/dev..."
    
    if [ "$CREATE_DEVICES" != "true" ]; then
        echo "  ⚠ Skipped (requires root privileges)"
        echo "    Run this script with sudo to create device nodes"
        return
    fi
    
    cd $ROOTFS/dev
    
    # Console and null devices (essential)
    mknod -m 622 console c 5 1
    mknod -m 666 null c 1 3
    mknod -m 666 zero c 1 5
    
    # TTY devices
    mknod -m 666 tty c 5 0
    mknod -m 620 tty0 c 4 0
    mknod -m 620 tty1 c 4 1
    
    # Random number generators
    mknod -m 444 random c 1 8
    mknod -m 444 urandom c 1 9
    
    # RAM disks
    mknod -m 660 ram0 b 1 0
    mknod -m 660 ram1 b 1 1
    
    # Loop devices
    mknod -m 660 loop0 b 7 0
    mknod -m 660 loop1 b 7 1
    
    # MMC/SD card devices (for BeagleBone Black)
    mknod -m 660 mmcblk0 b 179 0
    mknod -m 660 mmcblk0p1 b 179 1
    mknod -m 660 mmcblk0p2 b 179 2
    
    echo "  ✓ Device nodes created"
}

# Function to create configuration files
create_config_files() {
    local ROOTFS=$1
    echo "Creating configuration files in $ROOTFS/etc..."
    
    # /etc/inittab - init configuration
    cat > $ROOTFS/etc/inittab << 'EOF'
# /etc/inittab
::sysinit:/etc/init.d/rcS
::askfirst:-/bin/sh
::restart:/sbin/init
::ctrlaltdel:/sbin/reboot
::shutdown:/bin/umount -a -r
::shutdown:/sbin/swapoff -a
EOF
    
    # /etc/init.d/rcS - startup script
    cat > $ROOTFS/etc/init.d/rcS << 'EOF'
#!/bin/sh
# /etc/init.d/rcS - System initialization script

echo "Starting system initialization..."

# Mount essential filesystems
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev

# Create additional device nodes if needed
mkdir -p /dev/pts
mount -t devpts none /dev/pts

# Remount root as read-write if needed
mount -o remount,rw /

# Set hostname
echo "embedded-linux" > /proc/sys/kernel/hostname

# Network loopback
ifconfig lo 127.0.0.1 up

# Set PATH
export PATH=/bin:/sbin:/usr/bin:/usr/sbin

echo "System initialization complete."
echo ""
echo "=================================="
echo "  Embedded Linux System"
echo "=================================="
echo ""
EOF
    chmod +x $ROOTFS/etc/init.d/rcS
    
    # /etc/fstab - filesystem table
    cat > $ROOTFS/etc/fstab << 'EOF'
# /etc/fstab
proc            /proc           proc    defaults        0       0
sysfs           /sys            sysfs   defaults        0       0
devtmpfs        /dev            devtmpfs defaults       0       0
tmpfs           /tmp            tmpfs   defaults        0       0
EOF
    
    # /etc/passwd - user accounts
    cat > $ROOTFS/etc/passwd << 'EOF'
root:x:0:0:root:/root:/bin/sh
daemon:x:1:1:daemon:/usr/sbin:/bin/false
bin:x:2:2:bin:/bin:/bin/false
sys:x:3:3:sys:/dev:/bin/false
nobody:x:65534:65534:nobody:/nonexistent:/bin/false
EOF
    
    # /etc/group - group accounts
    cat > $ROOTFS/etc/group << 'EOF'
root:x:0:
daemon:x:1:
bin:x:2:
sys:x:3:
adm:x:4:
tty:x:5:
disk:x:6:
audio:x:29:
video:x:44:
nogroup:x:65534:
EOF
    
    # /etc/shadow - password shadow file
    cat > $ROOTFS/etc/shadow << 'EOF'
root::10933:0:99999:7:::
daemon:*:10933:0:99999:7:::
bin:*:10933:0:99999:7:::
sys:*:10933:0:99999:7:::
nobody:*:10933:0:99999:7:::
EOF
    chmod 640 $ROOTFS/etc/shadow
    
    # /etc/profile - shell environment
    cat > $ROOTFS/etc/profile << 'EOF'
# /etc/profile
export PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PS1='\u@\h:\w\$ '
export HOME=/root

if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
EOF
    
    # /etc/hostname
    echo "embedded-linux" > $ROOTFS/etc/hostname
    
    # /etc/hosts
    cat > $ROOTFS/etc/hosts << 'EOF'
127.0.0.1       localhost
127.0.1.1       embedded-linux
EOF
    
    # /etc/issue - login banner
    cat > $ROOTFS/etc/issue << 'EOF'
Embedded Linux System
Kernel \r on \m

EOF
    
    # /etc/network/interfaces - network interface configuration
    cat > $ROOTFS/etc/network/interfaces << 'EOF'
# Loopback interface
auto lo
iface lo inet loopback

# Ethernet interface (eth0)
# For static IP, uncomment and configure:
# auto eth0
# iface eth0 inet static
#     address 192.168.1.101
#     netmask 255.255.255.0
#     network 192.168.1.0
#     gateway 192.168.1.1

# For DHCP, uncomment:
# auto eth0
# iface eth0 inet dhcp
EOF
    
    # /etc/nsswitch.conf - Name Service Switch configuration
    cat > $ROOTFS/etc/nsswitch.conf << 'EOF'
passwd:     files
group:      files
shadow:     files
hosts:      files dns
networks:   files
protocols:  files
services:   files
EOF
    
    # Copy standard network configuration files from host
    if [ -f /etc/services ]; then
        cp /etc/services $ROOTFS/etc/
    fi
    
    if [ -f /etc/protocols ]; then
        cp /etc/protocols $ROOTFS/etc/
    fi
    
    # DHCP client default script (if using udhcpc)
    cat > $ROOTFS/usr/share/udhcpc/default.script << 'EOF'
#!/bin/sh
# udhcpc script for BusyBox

[ -n "$broadcast" ] && BROADCAST="broadcast $broadcast"
[ -n "$subnet" ] && NETMASK="netmask $subnet"

case "$1" in
    deconfig)
        ifconfig $interface 0.0.0.0
        ;;
    renew|bound)
        ifconfig $interface $ip $BROADCAST $NETMASK
        if [ -n "$router" ]; then
            echo "Deleting routers"
            while route del default gw 0.0.0.0 dev $interface 2>/dev/null; do
                :
            done
            for i in $router; do
                route add default gw $i dev $interface
            done
        fi
        echo -n > $RESOLV_CONF
        [ -n "$domain" ] && echo "search $domain" >> $RESOLV_CONF
        for i in $dns; do
            echo "nameserver $i" >> $RESOLV_CONF
        done
        ;;
esac

exit 0
EOF
    chmod +x $ROOTFS/usr/share/udhcpc/default.script
    
    echo "  ✓ Configuration files created"
}

# Function to set permissions
set_permissions() {
    local ROOTFS=$1
    echo "Setting file permissions in $ROOTFS..."
    
    # Set ownership (only works if running as root)
    if [ "$CREATE_DEVICES" = "true" ]; then
        chown -R root:root $ROOTFS/*
        echo "  ✓ Ownership set to root"
    else
        echo "  ⚠ Ownership not changed (requires root)"
    fi
    
    # Set permissions for sensitive files
    chmod 755 $ROOTFS/bin/*
    chmod 755 $ROOTFS/sbin/* 2>/dev/null || true
    chmod 755 $ROOTFS/etc/init.d/*
    chmod 644 $ROOTFS/etc/passwd
    chmod 644 $ROOTFS/etc/group
    chmod 640 $ROOTFS/etc/shadow
    chmod 1777 $ROOTFS/tmp  # Sticky bit on /tmp
    
    echo "  ✓ Permissions set"
}

# Function to display summary
display_summary() {
    local ROOTFS=$1
    echo ""
    echo "Summary for $ROOTFS:"
    echo "  - Directories: $(find $ROOTFS -type d | wc -l)"
    echo "  - Files: $(find $ROOTFS -type f | wc -l)"
    echo "  - Symlinks: $(find $ROOTFS -type l | wc -l)"
    echo "  - Size: $(du -sh $ROOTFS | cut -f1)"
}

# Main execution
main() {
    echo ""
    echo "Setting up BeagleBone Black root filesystem..."
    echo "========================================="
    create_directory_structure $ROOTFS_BBB
    install_busybox $ROOTFS_BBB $ARM_CORTEX_A8_TOOLCHAIN
    install_libraries $ROOTFS_BBB $ARM_CORTEX_A8_TOOLCHAIN
    create_device_nodes $ROOTFS_BBB
    create_config_files $ROOTFS_BBB
    set_permissions $ROOTFS_BBB
    display_summary $ROOTFS_BBB
    
    echo ""
    echo "Setting up QEMU root filesystem..."
    echo "========================================="
    create_directory_structure $ROOTFS_QEMU
    install_busybox $ROOTFS_QEMU $ARM_QEMU_TOOLCHAIN
    install_libraries $ROOTFS_QEMU $ARM_QEMU_TOOLCHAIN
    create_device_nodes $ROOTFS_QEMU
    create_config_files $ROOTFS_QEMU
    set_permissions $ROOTFS_QEMU
    display_summary $ROOTFS_QEMU
    
    echo ""
    echo "========================================="
    echo "✓ Root filesystem setup complete!"
    echo "========================================="
    echo ""
    echo "Next steps:"
    echo "  1. Test with QEMU: See run-qemu-initramfs.sh"
    echo "  2. Create initramfs: See create-initramfs.sh"
    echo "  3. Deploy to BeagleBone Black"
    echo ""
    
    if [ "$CREATE_DEVICES" != "true" ]; then
        echo "⚠ Device nodes were not created!"
        echo "  To create device nodes, run:"
        echo "  sudo $0"
        echo ""
    fi
}

main

