#!/bin/bash
set -e

if [[ $# -lt 5 ]]; then
    echo "USAGE: $0 <flavor> <image> <network_name> <key_name> <vm_name> [OPTIONAL]<availability_zone> [OPTIONAL]<config_drive_BOOLEAN>"
    exit 1
fi

AVAILABITY_ZONE=""
if [[ "$6" != "" ]]; then
    AVAILABITY_ZONE="--availability-zone=$6"
fi

CONFIG_DRIVE=""
if [[ "$7" != "" ]]; then
    CONFIG_DRIVE="--config-drive=$7"
fi

NETWORK_ID=`neutron net-show $3 | grep " id " | awk '{print $4}'`
echo "nova boot --flavor $1 --image $2 --nic net-id=$NETWORK_ID --key-name=$4 $5 $AVAILABITY_ZONE $CONFIG_DRIVE"
nova boot --flavor $1 --image $2 --nic net-id=$NETWORK_ID --key-name=$4 $5 $AVAILABITY_ZONE $CONFIG_DRIVE
