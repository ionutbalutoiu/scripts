#!/bin/bash
set -e

if [ $# -ne 7 ]; then
    echo "USAGE: $0 <public_net_CIDR> <public_net_gateway> <start_ip> <end_ip> <private_net_CIDR> <private_net_DNS> <networks_type>"
    exit 1
fi

neutron net-create --router:external --provider:network_type $7 public
neutron subnet-create public $1 --gateway $2 --allocation-pool start=$3,end=$4 --name public --disable-dhcp

neutron router-create public_router
neutron router-gateway-set public_router public

neutron net-create --shared --provider:network_type $7 private
neutron subnet-create private $5 --name private --dns-nameserver $6
neutron router-interface-add public_router private
