#!/usr/bin/env bash
set -e

if [ ! "$OS_TENANT_NAME" ] && [ ! "$OS_PROJECT_NAME" ]; then
    echo "Either \$OS_TENANT_NAME or \$OS_PROJECT_NAME must be set."
    exit 1
fi

TENANT="$OS_PROJECT_NAME"
if [ ! "$TENANT" ] && [ "$OS_TENANT_NAME" ]; then
    TENANT="$OS_TENANT_NAME"
fi

SECGROUP_NAME_OR_ID="default"
if [ $# -eq 1 ]; then
    SECGROUP_NAME_OR_ID="$1"
elif [ $# -gt 1 ]; then
    echo "USAGE: OS_PROJECT_NAME="project_name" $0 [\$SECGROUP_NAME_OR_ID]"
    exit 2
fi

# NOTE: tenant presumed existing:
TENANT_ID=`openstack project list | grep $OS_PROJECT_NAME | awk '{print $2}'`

SECGROUP_ID=`neutron security-group-list | grep "$TENANT_ID" | grep "$SECGROUP_NAME_OR_ID" | awk '{print $2}'`
if [ ! "$SECGROUP_ID" ]; then
    echo "Could not locate secgroup:$SECGROUP_NAME_OR_ID"
fi

neutron security-group-rule-create \
    --remote-ip-prefix=0.0.0.0/0 --direction=ingress \
    "$SECGROUP_ID"
