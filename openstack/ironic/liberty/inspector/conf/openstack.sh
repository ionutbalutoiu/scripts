#!/usr/bin/env bash

if [[ $# -ne 8 ]]; then
    echo "USAGE: $0 <mysql_db_host>" \
                  "<inspector_db_user_password>" \
                  "<ironic_inspector_private_ip>" \
                  "<keystone_auth_uri>" \
                  "<keystone_identity_uri>" \
                  "<keystone_admin_user>" \
                  "<keystone_admin_password>" \
                  "<keystone_admin_tenant_name>"
    exit 1
fi

MYSQL_HOST="$1"
MYSQL_INSPECTOR_DB_USER_PASSWORD="$2"
IRONIC_HOST="$3"
KEYSTONE_AUTH_URI="$4"
KEYSTONE_IDENTITY_URI="$5"
KEYSTONE_ADMIN_USER="$6"
KEYSTONE_ADMIN_PASSWORD="$7"
KEYSTONE_ADMIN_TENANT_NAME="$8"
IRONIC_USER="ironic"
IRONIC_INSPECTOR_ETC="/etc/ironic-inspector"
IRONIC_INSPECTOR_LOG="/var/log/ironic-inspector"
DNSMASQ_INTERFACE="eth1"

if [[ ! -d $IRONIC_INSPECTOR_ETC ]]; then
    mkdir -p $IRONIC_INSPECTOR_ETC
fi

cat << EOF > $IRONIC_INSPECTOR_ETC/inspector.conf
[DEFAULT]
listen_address = 0.0.0.0
listen_port = 5050
auth_strategy = keystone
timeout = 3600
rootwrap_config = $IRONIC_INSPECTOR_ETC/rootwrap.conf
debug = true
verbose = true
log_file = ironic-inspector.log
log_dir = $IRONIC_INSPECTOR_LOG

[database]
connection = mysql+pymysql://inspector:$MYSQL_INSPECTOR_DB_USER_PASSWORD@$MYSQL_HOST/inspector?charset=utf8

[firewall]
manage_firewall = true
dnsmasq_interface = $DNSMASQ_INTERFACE
firewall_update_period = 15
firewall_chain = ironic-inspector

[ironic]
auth_strategy = keystone
ironic_url = http://$IRONIC_HOST:6385/
os_auth_url = $KEYSTONE_AUTH_URI
os_username = $KEYSTONE_ADMIN_USER
os_password = $KEYSTONE_ADMIN_PASSWORD
os_tenant_name = $KEYSTONE_ADMIN_TENANT_NAME
identity_uri = $KEYSTONE_IDENTITY_URI
os_endpoint_type = internalurl
os_service_type = baremetal

[keystone_authtoken]
auth_uri = $KEYSTONE_AUTH_URI
region_name = RegionOne
identity_uri = $KEYSTONE_IDENTITY_URI
admin_user = $KEYSTONE_ADMIN_USER
admin_password = $KEYSTONE_ADMIN_PASSWORD
admin_tenant_name = $KEYSTONE_ADMIN_TENANT_NAME

[processing]
add_ports = pxe
keep_ports = all
overwrite_existing = true
ramdisk_logs_dir = $IRONIC_INSPECTOR_LOG
always_store_ramdisk_logs = true

EOF

chmod 600 $IRONIC_INSPECTOR_ETC/inspector.conf
chown $IRONIC_USER:$IRONIC_USER $IRONIC_INSPECTOR_ETC/inspector.conf
