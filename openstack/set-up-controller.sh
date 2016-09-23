#!/usr/bin/env bash

. ~/keystonerc_v2
$DIR/openstack/glance/upload-cirros-vhdx.sh
$DIR/openstack/nova/open-all-ports.sh default
$DIR/openstack/neutron/create-topology.sh 192.168.101.0/24 192.168.101.3 192.168.101.222 192.168.101.230 10.0.1.0/24 192.168.101.3 vlan
