#!/usr/bin/env bash
set -e

if [ $# -ne 1 ]; then
    echo "USAGE: $0 <security_group_name>"
    exit 1
fi
nova secgroup-add-rule "$1" tcp 1 65535 0.0.0.0/0
nova secgroup-add-rule "$1" udp 1 65535 0.0.0.0/0
nova secgroup-add-rule "$1" icmp -1 -1 0.0.0.0/0
