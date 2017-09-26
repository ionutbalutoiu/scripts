#!/usr/bin/env bash
set -e

DIR=$(dirname $0)

$DIR/glance/upload-cirros-vhdx.sh
$DIR/neutron/create-topology.sh 192.168.101.0/24 192.168.101.2 192.168.101.210 192.168.101.230 192.168.101.2

openstack keypair create key > $HOME/admin_nova_key
chmod 600 $HOME/admin_nova_key

openstack flavor create --id 1 --ram 512  --disk 1   --vcpus 1 m1.tiny
openstack flavor create --id 2 --ram 1024 --disk 10  --vcpus 1 m1.small
openstack flavor create --id 3 --ram 2048 --disk 30  --vcpus 2 m1.medium
openstack flavor create --id 4 --ram 3072 --disk 50  --vcpus 2 m1.large
