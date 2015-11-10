#!/usr/bin/env bash

if [[ $# -ne 8 ]]; then
    echo "USAGE: $0 <enabled_drivers>" \
                   "<ironic_private_ip>" \
                   "<ironic_db_name>" \
                   "<ironic_db_user>" \
                   "<ironic_db_user_password>" \
                   "<tftp_root>" \
                   "<http_root>" \
                   "<rabbitmq_user_password>"
    exit 1
fi

ENABLED_DRIVERS="$1"
IRONIC_PRIVATE_IP="$2"
DB_NAME="$3"
DB_USER="$4"
DB_USER_PASSWORD="$5"
TFTP_ROOT="$6"
HTTP_ROOT="$7"
RABBITMQ_USER_PASSWORD="$8"
LOG_DIR="/var/log/ironic"
ETC_DIR="/etc/ironic"

cat << EOF > $ETC_DIR/ironic.conf
[DEFAULT]
log_dir = $LOG_DIR
auth_strategy = noauth
enabled_drivers = $ENABLED_DRIVERS
debug = True
verbose = True

[conductor]
api_url = http://$IRONIC_PRIVATE_IP:6385
clean_nodes = false

[api]
host_ip = 0.0.0.0
port = 6385

[database]
connection = mysql+pymysql://${DB_USER}:${DB_USER_PASSWORD}@127.0.0.1/${DB_NAME}?charset=utf8

[dhcp]
dhcp_provider = none

[glance]
auth_strategy = noauth

[neutron]
auth_strategy = noauth

[pxe]
tftp_root = $TFTP_ROOT
tftp_server = $IRONIC_PRIVATE_IP
ipxe_enabled = True
pxe_bootfile_name = undionly.kpxe
pxe_config_template = \$pybasedir/drivers/modules/ipxe_config.template

[deploy]
http_root = $HTTP_ROOT
http_url = http://$IRONIC_PRIVATE_IP:8080

[oslo_messaging_rabbit]
rabbit_userid = openstack
rabbit_password = $RABBITMQ_USER_PASSWORD
EOF
