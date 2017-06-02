#!/bin/bash
set -e

if [ $# -ne 5 ]; then
    echo "USAGE: $0 <public_net_CIDR> <public_net_gateway> <start_ip> <end_ip> <private_nets_dns>"
    exit 1
fi

openstack network create --external --provider-network-type flat --provider-physical-network external --share public
openstack subnet create --network public --subnet-range $1 --allocation-pool start=$3,end=$4 --gateway $2 --no-dhcp --ip-version 4 public_subnet

openstack router create public_router
openstack router set --external-gateway public public_router

openstack network create --provider-network-type vlan --provider-physical-network data --share private_vlan
openstack subnet create --network private_vlan --subnet-range 10.1.0.0/24 --ip-version 4 private_vlan_subnet
openstack router add subnet public_router private_vlan_subnet

openstack network create --provider-network-type vxlan --share private_vxlan
openstack subnet create --network private_vxlan --subnet-range 10.1.3.0/24 --ip-version 4 private_vxlan_subnet
openstack router add subnet public_router private_vxlan_subnet
