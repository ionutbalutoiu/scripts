#!/bin/bash
set -e

if [ $# -ne 5 ]; then
    echo "USAGE: $0 <flavor_name/id> <keypair_name> <image_name/id> <network_name> <vm_name>"
    exit 1
fi

NET_ID=`neutron net-show $4 | awk '{if (NR==5){print $4}}'`
nova boot --flavor $1 --key-name $2 --image $3 --nic net-id=$NET_ID $5
