#!/usr/bin/env bash

wget http://balutoiu.com/ionut/cirros-gen2.vhdx -O /tmp/cirros.vhdx
glance image-create --visibility public --property hw_machine_type=hyperv-gen2 --property hypervisor_version_requires='>=6.3' --property hypervisor_type=hyperv --name cirros --disk-format vhd --container-format bare --file /tmp/cirros.vhdx
rm /tmp/cirros.vhdx --progress
