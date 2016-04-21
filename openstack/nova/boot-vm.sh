#!/bin/bash

if [[ $# -lt 5 ]]; then
	echo "USAGE: $0 <flavor> <image> <network_name> <key_name> <vm_name> [OPTIONAL]<availability_zone>"
	exit 1
fi

AVAILABITY_ZONE=""
if [[ "$6" != "" ]]; then
    AVAILABITY_ZONE="--availability-zone=$6"
fi

NETWORK_ID=`neutron net-show private | grep " id " | awk '{print $4}'`
nova boot --flavor $1 --image $2 --nic net-id=$NETWORK_ID --key-name=$4 $5 $AVAILABITY_ZONE --config-drive=true
#nova boot --flavor $1 --image $2 --nic net-id=$NETWORK_ID --key-name=$4 $5 $AVAILABITY_ZONE

#echo "Sleeping 5 seconds..."
#sleep 5
#IP=`nova floating-ip-create public | awk '{if(NR==4){print $4}}'`
#nova floating-ip-associate $5 $IP
