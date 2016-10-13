#!/usr/bin/env bash

if [[ $# -ne 4 ]]; then
    echo "USAGE: $0 <keystone_ip> <tenant_name> <user_name> <user_password>"
    exit 1
fi

cat << EOF > keystonerc_v2
export OS_AUTH_URL="http://$1:5000/v2.0"
export OS_TENANT_NAME="$2"
export OS_USERNAME="$3"
export OS_PASSWORD="$4"
export PS1='[\u@\h \W(keystone_$3_v2)]\$ '
EOF

cat << EOF > keystonerc_v3
export OS_AUTH_URL="http://$1:5000/v3"
export OS_TENANT_NAME="$2"
export OS_PROJECT_NAME="$2"
export OS_USERNAME="$3"
export OS_PASSWORD="$4"
export OS_REGION_NAME="RegionOne"
export OS_USER_DOMAIN_NAME="admin_domain"
export OS_PROJECT_DOMAIN_NAME="Default"
export OS_IDENTITY_API_VERSION=3
export OS_VOLUME_API_VERSION=2
export PS1='[\u@\h \W(keystone_$3_v3)]\$ '
EOF
