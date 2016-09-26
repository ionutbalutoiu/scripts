#!/usr/bin/env bash
set -e

$DIR/glance/upload-cirros-vhdx.sh
$DIR/nova/open-all-ports.sh default
$DIR/neutron/create-topology.sh 192.168.101.0/24 192.168.101.3 192.168.101.222 192.168.101.230 10.0.1.0/24 192.168.101.3 vlan
