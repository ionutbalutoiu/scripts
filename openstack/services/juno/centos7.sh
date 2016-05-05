#!/usr/bin/env bash
set -e

if [ $# -ne 1 ]; then
    echo "USAGE: $0 <service_action>"
    exit 1
fi

ACTION=$1

service mariadb $ACTION
service rabbitmq-server $ACTION
service openstack-keystone $ACTION

service openstack-glance-api $ACTION
service openstack-glance-registry $ACTION

service openstack-nova-api $ACTION
service openstack-nova-cert $ACTION
service openstack-nova-consoleauth $ACTION
service openstack-nova-scheduler $ACTION
service openstack-nova-conductor $ACTION
service openstack-nova-novncproxy $ACTION
service libvirtd $ACTION
service openstack-nova-compute $ACTION

service neutron-server $ACTION
service openvswitch $ACTION
service neutron-ovs-cleanup $ACTION
service neutron-openvswitch-agent $ACTION
service neutron-l3-agent $ACTION
service neutron-dhcp-agent $ACTION
service neutron-metadata-agent $ACTION

service memcached $ACTION
service httpd $ACTION

service openstack-cinder-api $ACTION
service openstack-cinder-scheduler $ACTION
service lvm2-lvmetad $ACTION
service openstack-cinder-volume $ACTION
service target $ACTION

service openstack-heat-api $ACTION
service openstack-heat-api-cfn $ACTION
service openstack-heat-engine $ACTION

service openstack-losetup $ACTION 
