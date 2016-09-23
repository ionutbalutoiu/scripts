#!/usr/bin/env bash

if [[ "$1" = "" ]]; then
    echo "USAGE: $0 <keystone_ip>"
    exit 1
fi

cat << EOF > ~/keystonerc_v2
export OS_AUTH_URL=http://$1:35357/v2.0
export OS_TENANT_NAME="admin"
export OS_USERNAME="admin"
export OS_PASSWORD="Passw0rd"
export PS1='[\u@\h \W(keystone_admin_v2)]\$ '
EOF

cat << EOF > ~/keystonerc_v3
export OS_USERNAME=admin
export OS_PASSWORD=Passw0rd
export OS_TENANT_NAME=admin
export OS_PROJECT_NAME=admin
export OS_AUTH_URL=http://$1:35357/v3
export OS_REGION_NAME=RegionOne
export OS_VOLUME_API_VERSION=2
export OS_IDENTITY_API_VERSION=3
export OS_USER_DOMAIN_NAME=admin_domain
export OS_PROJECT_DOMAIN_NAME=\${OS_PROJECT_DOMAIN_NAME:-"Default"}
export PS1='[\u@\h \W(keystone_admin_v3)]\$ '
EOF

cat << EOF > ~/keystonerc_token
export OS_URL=http://$1:35357/v3
export OS_TOKEN=Passw0rd
export PS1='[\u@\h \W(keystone_admin_token)]\$ '
EOF
