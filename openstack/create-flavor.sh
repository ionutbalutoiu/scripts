#!/bin/bash
set -e

if [ $# -ne 4 ]; then
    echo "USAGE: $0 <flavor_name> <ram_mb> <disk_gb> <cpus>"
    exit 1
fi

nova flavor-create $1 auto $2 $3 $4

# ./create-flavor.sh bare-metal 32768 100 8
