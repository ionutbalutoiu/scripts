#!/usr/bin/env bash

sudo apt-get install git -y
git clone https://github.com/cloudbase/ci-overcloud-init-scripts.git /tmp/ci-overcloud-init-scripts
glance image-create --visibility public --property hypervisor_type=hyperv --name cirros --disk-format vhd --container-format bare --file /tmp/ci-overcloud-init-scripts/scripts/devstack_vm/cirros.vhdx
rm -rf /tmp/ci-overcloud-init-scripts
