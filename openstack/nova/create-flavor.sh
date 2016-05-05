#!/bin/bash
set -e

if [ $# -ne 4 ]; then
    echo "USAGE: $0 <flavor_name> <ram_mb> <disk_gb> <cpus> [OPTIONAL]<id>"
    exit 1
fi

ID="auto"
if [[ "$5" != "" ]]; then
    ID="$5"
fi

nova flavor-create $1 $ID $2 $3 $4
