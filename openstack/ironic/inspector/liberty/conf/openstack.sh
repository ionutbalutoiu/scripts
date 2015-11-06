#!/usr/bin/env bash
set -e

if [[ $# -ne 13 ]]; then
    echo "USAGE: $0 <mysql_db_host>" \
                   "<mysql_db_name>" \
                   "<mysql_db_user>" \
                   "<mysql_db_user_password>" \
                   "<ironic_host>" \
                   "<keystone_public_endpoint>" \
                   "<keystone_admin_endpoint>" \
                   "<keystone_admin_user>" \
                   "<keystone_admin_password>" \
                   "<keystone_admin_tenant_name>" \
                   "<inspector_etc_dir>" \
                   "<inspector_log_dir>" \
                   "<inspector_dnsmasq_interface>"
    exit 1
fi

MYSQL_HOST="$1"
MYSQL_DB_NAME="$2"
MYSQL_DB_USER="$3"
MYSQL_DB_USER_PASSWORD="$4"
IRONIC_HOST="$5"
KEYSTONE_PUBLIC_ENDPOINT="$6"
KEYSTONE_ADMIN_ENDPOINT="$7"
KEYSTONE_ADMIN_USER="$8"
KEYSTONE_ADMIN_PASSWORD="$9"
KEYSTONE_ADMIN_TENANT_NAME="${10}"
IRONIC_INSPECTOR_ETC="${11}"
IRONIC_INSPECTOR_LOG="${12}"
DNSMASQ_INTERFACE="${13}"

if [[ ! -d $IRONIC_INSPECTOR_ETC ]]; then
    mkdir -p $IRONIC_INSPECTOR_ETC
fi

cat << EOF > $IRONIC_INSPECTOR_ETC/inspector.conf
[DEFAULT]
debug = true
verbose = true
listen_address = 0.0.0.0
listen_port = 5050
auth_strategy = keystone
timeout = 3600
rootwrap_config = $IRONIC_INSPECTOR_ETC/rootwrap.conf
log_file = ironic-inspector.log
log_dir = $IRONIC_INSPECTOR_LOG

[database]
connection = mysql+pymysql://$MYSQL_DB_USER:$MYSQL_DB_USER_PASSWORD@$MYSQL_HOST/$MYSQL_DB_NAME?charset=utf8

[firewall]
manage_firewall = true
dnsmasq_interface = $DNSMASQ_INTERFACE
firewall_update_period = 15
firewall_chain = ironic-inspector

[ironic]
auth_strategy = keystone
ironic_url = http://$IRONIC_HOST:6385
identity_uri = $KEYSTONE_ADMIN_ENDPOINT
os_auth_url = $KEYSTONE_PUBLIC_ENDPOINT/v2.0
os_username = $KEYSTONE_ADMIN_USER
os_password = $KEYSTONE_ADMIN_PASSWORD
os_tenant_name = $KEYSTONE_ADMIN_TENANT_NAME

[processing]
add_ports = pxe
keep_ports = all
overwrite_existing = true
ramdisk_logs_dir = $IRONIC_INSPECTOR_LOG
always_store_ramdisk_logs = true
EOF

chmod 600 $IRONIC_INSPECTOR_ETC/inspector.conf
