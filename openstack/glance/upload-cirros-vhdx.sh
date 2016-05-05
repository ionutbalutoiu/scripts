#!/usr/bin/env bash

wget https://github.com/cloudbase/ci-overcloud-init-scripts/raw/master/scripts/devstack_vm/cirros.vhdx -O /tmp/cirros.vhdx
glance image-create --visibility public --property hypervisor_type=hyperv --name cirros --disk-format vhd --container-format bare --file /tmp/cirros.vhdx
rm /tmp/cirros.vhdx
