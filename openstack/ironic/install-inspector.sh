#!/usr/bin/env bash

if [[ $# -ne 3 ]]; then
    echo "USAGE: $0 <ironic_inspector_private_ip>" \
                   "<discovery_kernel_img_name>" \
                   "<discovery_ramdisk_img_name>"
    exit 1
fi

# GLOBAL PARAMETERS
IRONIC_INSPECTOR_PRIVATE_IP="$1"
DISCOVERY_KERNEL_IMG_NAME="$2"
DISCOVERY_RAMDISK_IMG_NAME="$3"
GIT_BRANCH="stable/liberty"
IRONIC_USER="ironic"
IRONIC_INSPECTOR_ETC="/etc/ironic-inspector"
IRONIC_INSPECTOR_LOG="/var/log/ironic-inspector"
IRONIC_INSPECTOR_GIT_URL="https://github.com/openstack/ironic-inspector.git"
IRONIC_INSPECTOR_CLIENT_GIT_URL="https://github.com/openstack/python-ironic-inspector-client.git"
TFTP_BOOT="/tftpboot"
###################

# Install ironic-inspector from git
grep $IRONIC_USER /etc/passwd -q || useradd $IRONIC_USER
for i in $IRONIC_INSPECTOR_ETC $IRONIC_INSPECTOR_LOG; do mkdir -p $i; done
TMP_DIR="/tmp/`basename $IRONIC_INSPECTOR_GIT_URL`"
git clone $IRONIC_INSPECTOR_GIT_URL $TMP_DIR
pushd $TMP_DIR
git checkout $GIT_BRANCH
pip install -r requirements.txt
python setup.py install
for i in $IRONIC_INSPECTOR_ETC $IRONIC_INSPECTOR_LOG; do chown -R $IRONIC_USER:$IRONIC_USER $i; done
cp -rf rootwrap.conf rootwrap.d $IRONIC_INSPECTOR_ETC
chown root:root -R $IRONIC_INSPECTOR_ETC/rootwrap.conf $IRONIC_INSPECTOR_ETC/rootwrap.d
popd
rm -rf $TMP_DIR

# Add ironic-inspector to sudoers
cat << EOF > /etc/sudoers.d/ironic_inspector_sudoers
Defaults:$IRONIC_USER !requiretty

$IRONIC_USER ALL = (root) NOPASSWD: /usr/local/bin/ironic-inspector-rootwrap $IRONIC_INSPECTOR_ETC/rootwrap.conf *
EOF

# Prepare default tftp file
mkdir -p $TFTP_BOOT/pxelinux.cfg
cat << EOF > $TFTP_BOOT/pxelinux.cfg/default
default introspect

label introspect
kernel $DISCOVERY_KERNEL_IMG_NAME
append initrd=$DISCOVERY_RAMDISK_IMG_NAME discoverd_callback_url=http://$IRONIC_INSPECTOR_PRIVATE_IP:5050/v1/continue

ipappend 3
EOF

# Create database tables
ironic-inspector-dbsync --config-file $IRONIC_INSPECTOR_ETC/inspector.conf upgrade

# Create ironic-inspector upstart service
cat << EOF > /etc/init/ironic-inspector.conf
start on runlevel [2345]
stop on runlevel [016]
pre-start script
  mkdir -p /var/run/ironic
  chown -R $IRONIC_USER:$IRONIC_USER /var/run/ironic
end script
respawn
respawn limit 2 10

exec start-stop-daemon --start -c $IRONIC_USER --exec /usr/local/bin/ironic-inspector -- --config-file $IRONIC_INSPECTOR_ETC/inspector.conf --log-file $IRONIC_INSPECTOR_LOG/ironic-inspector.log
EOF

# Install python-client
$(dirname $0)/install-python-client.sh $IRONIC_INSPECTOR_CLIENT_GIT_URL $GIT_BRANCH

# Start service
service ironic-inspector restart
