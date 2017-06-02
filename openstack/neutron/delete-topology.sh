#!/usr/bin/env bash
set -e

# Delete all the routers
for ROUTER in `openstack router list | awk '{print $2}' | grep -E "[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}"`; do
    openstack router unset $ROUTER --external-gateway
    for PORT in `openstack port list --router $ROUTER | awk '{print $2}' | grep -Eo "[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}"`; do
        openstack router remove port $ROUTER $PORT
    done
    openstack router delete $ROUTER
done

# Delete all the networks' subnets
SUBNETS=""
for SUBNET in `openstack subnet list | awk '{print $2}' | grep -E "[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}"`; do
    SUBNETS="$SUBNETS $SUBNET"
done
if [[ ! -z $SUBNETS ]]; then
    openstack subnet delete $SUBNETS
fi

# Delete all the networks
NETWORKS=""
for NETWORK in `openstack network list | awk '{print $2}' | grep -E "[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}"`; do
    NETWORKS="$NETWORKS $NETWORK"
done
if [[ ! -z $NETWORKS ]]; then
    openstack network delete $NETWORKS
fi