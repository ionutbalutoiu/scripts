#!/usr/bin/env bash
set -e

if [[ $# -lt 1 ]]; then
    echo "USAGE: $0 <vm_name> [optional]<floating_ip>"
    exit 1
fi

if [[ -z $2 ]]; then
    FIP=$(openstack floating ip create public | egrep '^\|\sid\s+\|' | awk '{print $4}')
else
    FIP="$2"
fi

PORT_ID=$(openstack port list --server $1 | egrep "[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}" | head -1 | awk '{print $2}')
openstack floating ip set $FIP --port $PORT_ID
