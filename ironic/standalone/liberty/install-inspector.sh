#!/bin/bash

if [[ $# -ne 4 ]]; then
    echo "USAGE: $0 <mysql_db_host> <mysql_root_password> <ironic_inspector_private_ip> <ironic_host>"
    exit 1
fi

# GLOBAL PARAMETERS
MYSQL_HOST="$1"
MYSQL_ROOT_PASSWORD="$2"
IRONIC_INSPECTOR_PRIVATE_IP="$3"
IRONIC_HOST="$4"
GIT_BRANCH="stable/liberty"
IRONIC_USER="ironic"
IRONIC_INSPECTOR_ETC="/etc/ironic-inspector"
IRONIC_INSPECTOR_LOG="/var/log/ironic-inspector"
IRONIC_INSPECTOR_GIT_URL="https://github.com/openstack/ironic-inspector.git"
###################

# MySQL database creation
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "" &> /dev/null
if [[ $? -ne 0 ]]; then
    echo "ERROR: Wrong MySQL root password."
    exit 1
fi
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "USE inspector;" &> /dev/null
if [[ $? -eq 0 ]]; then
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "DROP DATABASE inspector;"
fi
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE inspector CHARACTER SET utf8;"
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON inspector.* TO 'inspector'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON inspector.* TO 'inspector'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"

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

# Create inspector.conf configuration file
cat << EOF > $IRONIC_INSPECTOR_ETC/inspector.conf
[DEFAULT]
listen_address = 0.0.0.0
listen_port = 5050
auth_strategy = noauth
debug = true
verbose = true
log_file = ironic-inspector.log
log_dir = $IRONIC_INSPECTOR_LOG

[database]
connection = mysql+pymysql://inspector:$MYSQL_ROOT_PASSWORD@$MYSQL_HOST/inspector?charset=utf8

[firewall]
manage_firewall = false

[ironic]
auth_strategy = noauth
ironic_url = http://$IRONIC_HOST:6385/

[keystone_authtoken]
admin_token = ' '
EOF
chmod 600 $IRONIC_INSPECTOR_ETC/inspector.conf
chown $IRONIC_USER:$IRONIC_USER $IRONIC_INSPECTOR_ETC/inspector.conf

# Add ironic-inspector to sudoers
cat << EOF > /etc/sudoers.d/ironic_inspector_sudoers
Defaults:$IRONIC_USER !requiretty

$IRONIC_USER ALL = (root) NOPASSWD: /usr/local/bin/ironic-inspector-rootwrap $IRONIC_INSPECTOR_ETC/rootwrap.conf *
EOF

# Prepare default tftp file
mkdir -p /tftpboot/pxelinux.cfg
cat << EOF > /tftpboot/pxelinux.cfg/default
default introspect

label introspect
kernel discovery.kernel
append initrd=discovery.initramfs discoverd_callback_url=http://$IRONIC_INSPECTOR_PRIVATE_IP:5050/v1/continue

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

# Start service
service ironic-inspector start
