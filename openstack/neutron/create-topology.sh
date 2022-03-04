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

openstack network create private
openstack subnet create --network private --subnet-range 10.33.22.0/24 --ip-version 4 --dns-nameserver $5 private_subnet
#openstack network create private --provider-network-type vlan --provider-physical-network external
#openstack subnet create --network private --subnet-range 10.33.22.0/24 --allocation-pool start=10.33.22.2,end=10.33.22.224 --ip-version 4 --dns-nameserver $5 private_subnet

openstack router add subnet public_router private_subnet
