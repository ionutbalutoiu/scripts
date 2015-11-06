#!/usr/bin/env bash
set -e

if [[ $# -ne 7 ]]; then
    echo "USAGE: $0 <ironic_inspector_private_ip>" \
                   "<discovery_kernel_img_name>" \
                   "<discovery_ramdisk_img_name>" \
                   "<tftpboot_dir>" \
                   "<dnsmasq_interface>" \
                   "<dnsmasq_dhcp_range>" \
                   "<inspector_user>"
    exit 1
fi

IRONIC_INSPECTOR_PRIVATE_IP="$1"
DISCOVERY_KERNEL_IMG_NAME="$2"
DISCOVERY_RAMDISK_IMG_NAME="$3"
TFTP_BOOT="$4"
DNSMASQ_INTERFACE="$5"
DNSMASQ_DHCP_RANGE="$6"
IRONIC_USER="$7"

mkdir -p $TFTP_BOOT
cp /usr/lib/syslinux/pxelinux.0 $TFTP_BOOT
mkdir -p $TFTP_BOOT/pxelinux.cfg

cat << EOF > $TFTP_BOOT/pxelinux.cfg/default
default introspect

label introspect
kernel $DISCOVERY_KERNEL_IMG_NAME
append initrd=$DISCOVERY_RAMDISK_IMG_NAME discoverd_callback_url=http://$IRONIC_INSPECTOR_PRIVATE_IP:5050/v1/continue

ipappend 3
EOF

# cat << EOF > $TFTP_BOOT/pxelinux.cfg/default
# default introspect

# label introspect
# kernel ironic-agent.vmlinuz
# append initrd=ironic-agent.initramfs ipa-inspection-callback-url=http://$IRONIC_INSPECTOR_PRIVATE_IP:5050/v1/continue systemd.journald.forward_to_console=yes

# ipappend 3
# EOF

cat << EOF > /etc/dnsmasq.conf
port=0
interface=$DNSMASQ_INTERFACE
bind-interfaces
dhcp-range=${DNSMASQ_DHCP_RANGE},12h
enable-tftp
tftp-root=$TFTP_BOOT
dhcp-boot=pxelinux.0
EOF

service dnsmasq restart
