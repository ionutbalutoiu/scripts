#!/usr/bin/env bash

if [[ $# -ne 3 ]]; then
    echo "USAGE: $0 <mysql_db_host>" \
                    "<inspector_db_user_password>" \
                    "<ironic_inspector_private_ip>"
    exit 1
fi

MYSQL_HOST="$1"
MYSQL_INSPECTOR_DB_USER_PASSWORD="$2"
IRONIC_HOST="$3"
IRONIC_INSPECTOR_ETC="/etc/ironic-inspector"
IRONIC_USER="ironic"
IRONIC_INSPECTOR_LOG="/var/log/ironic-inspector"

if [[ ! -d $IRONIC_INSPECTOR_ETC ]]; then
    mkdir -p $IRONIC_INSPECTOR_ETC
fi

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
connection = mysql+pymysql://inspector:$MYSQL_INSPECTOR_DB_USER_PASSWORD@$MYSQL_HOST/inspector?charset=utf8

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
