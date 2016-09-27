#!/usr/bin/env bash

wget http://balutoiu.com/ionut/cirros-gen2.vhdx -O /tmp/cirros-gen2.vhdx
openstack image create --public \
                       --property hw_machine_type=hyperv-gen2 \
                       --property hypervisor_version_requires='>=6.3' \
                       --property hypervisor_type=hyperv \
                       --disk-format vhd \
                       --container-format bare \
                       --file /tmp/cirros-gen2.vhdx \
                       cirros-gen2
rm /tmp/cirros-gen2.vhdx

wget https://github.com/cloudbase/ci-overcloud-init-scripts/raw/master/scripts/devstack_vm/cirros.vhdx -O /tmp/cirros-gen1.vhdx
openstack image create --public \
                       --property hypervisor_type=hyperv \
                       --disk-format vhd \
                       --container-format bare \
                       --file /tmp/cirros-gen1.vhdx \
                       cirros-gen1
rm /tmp/cirros-gen1.vhdx