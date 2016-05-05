#!/usr/bin/env bash
set -e

# Clear all gateways
for i in `neutron router-list | awk '{print $2}' | grep -E "[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}"`; do
    neutron router-gateway-clear $i
done

# Clear all interfaces from all existing routers
for router in `neutron router-list | awk '{print $2}' | grep -E "[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}"`; do
    for interface in `neutron router-port-list $router | awk '{print $8}' | grep -Eo "[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}"`; do
        neutron router-interface-delete $router $interface
    done
done

# Delete all routers
for i in `neutron router-list | awk '{print $2}' | grep -E "[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}"`; do
    neutron router-delete $i
done

# Delete all networks subnets
for i in `neutron subnet-list | awk '{print $2}' | grep -E "[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}"`; do
    neutron subnet-delete $i
done

# Delete all networks
for i in `neutron net-list | awk '{print $2}' | grep -E "[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}"`; do
    neutron net-delete $i
done