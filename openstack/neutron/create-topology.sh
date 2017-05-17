#!/bin/bash
set -e

if [ $# -ne 7 ]; then
    echo "USAGE: $0 <public_net_CIDR> <public_net_gateway> <start_ip> <end_ip> <private_net_CIDR> <private_net_DNS> <networks_type>"
    exit 1
fi

neutron net-create --router:external --provider:network_type flat --provider:physical_network external public
neutron subnet-create public $1 --gateway $2 --allocation-pool start=$3,end=$4 --name public --disable-dhcp

neutron router-create public_router
neutron router-gateway-set public_router public

neutron net-create --shared --provider:network_type $7 --provider:physical_network data private_vlan
neutron subnet-create private_vlan $5 --name private_vlan --dns-nameserver $6
neutron router-interface-add public_router private_vlan

neutron net-create --shared --provider:network_type vxlan private_vxlan
neutron subnet-create private_vxlan 10.0.3.0/24 --name private_vxlan --dns-nameserver 8.8.8.8
neutron router-interface-add public_router private_vxlan
