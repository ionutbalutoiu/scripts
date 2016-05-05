#!/usr/bin/env bash

wget http://download.cirros-cloud.net/0.3.3/cirros-0.3.3-x86_64-disk.img -O /tmp/cirros.img
glance image-create --name=cirros --container-format=bare --file=/tmp/cirros.img --disk-format=qcow2 --progress
rm /tmp/cirros.img
