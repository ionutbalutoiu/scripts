#!/usr/bin/env bash
set -e

DIR=$(dirname $0)

sudo apt-get install python-openstackclient -y

$DIR/glance/upload-cirros-vhdx.sh
$DIR/nova/open-all-ports.sh default
$DIR/neutron/create-topology.sh 192.168.101.0/24 192.168.101.2 192.168.101.222 192.168.101.230 10.0.1.0/24 192.168.101.2 vlan
nova keypair-add key > $DIR/vm_key
chmod 600 $DIR/vm_key
nova flavor-create test 1 512 1 1
