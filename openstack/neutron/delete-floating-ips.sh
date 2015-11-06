#!/usr/bin/env bash
set -e

IP=`neutron floatingip-list | awk '{if (NR==4) {print $2}}'`
while [[ ! -z $IP ]]; do
    neutron floatingip-delete $IP
    IP=`neutron floatingip-list | awk '{if (NR==4) {print $2}}'`
done
