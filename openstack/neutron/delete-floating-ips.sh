#!/usr/bin/env bash
set -e

FLOATING_IPS=""
for IP in `openstack floating ip list | awk '{print $2}' | grep -E "[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}"`; do
    FLOATING_IPS="$FLOATING_IPS $IP"
done
if [[ ! -z $FLOATING_IPS ]]; then
    openstack floating ip delete $FLOATING_IPS
fi
