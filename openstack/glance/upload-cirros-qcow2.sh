#!/usr/bin/env bash

wget http://download.cirros-cloud.net/0.3.3/cirros-0.3.3-x86_64-disk.img -O /tmp/cirros.img
openstack image create --public --disk-format qcow2 --container-format bare --file /tmp/cirros-gen1.vhdx cirros-qcow2
rm /tmp/cirros.img
