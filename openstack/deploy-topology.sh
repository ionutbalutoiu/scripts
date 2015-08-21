#!/bin/bash
set -e

if [ $# -ne 5 ]; then
    echo "USAGE: $0 <public_net_CIDR> <public_net_gateway> <start_ip> <end_ip> <networks_type>"
    exit 1
fi

neutron net-create --shared --router:external --provider:network_type $5 public
neutron subnet-create public $1 --gateway $2 --allocation-pool start=$3,end=$4 --name public --disable-dhcp

neutron router-create public_router
neutron router-gateway-set public_router public

neutron net-create --provider:network_type $5 private
neutron subnet-create private 10.0.1.0/24 --name private --dns-nameserver 8.8.8.8
neutron router-interface-add public_router private
