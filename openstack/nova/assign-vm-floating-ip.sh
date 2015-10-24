#!/bin/bash
set -e

if [ $# -ne 2 ]; then
    echo "USAGE: $0 <vm_name/id> <public_network_name/id>"
    exit 1
fi

IP=`nova floating-ip-create public | awk '{if (NR==4) {print $4}}'`
nova floating-ip-associate $1 $IP
echo "VM $1 has floating IP $IP"
