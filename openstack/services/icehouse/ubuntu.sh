#!/usr/bin/env bash
set -e

if [ $# -ne 1 ]; then
    echo "USAGE: $0 <service_action>"
    exit 1
fi

ACTION=$1

service mysql $ACTION
service rabbitmq-server $ACTION
service keystone $ACTION

service glance-api $ACTION
service glance-registry $ACTION

service nova-api $ACTION
service nova-cert $ACTION
service nova-consoleauth $ACTION
service nova-scheduler $ACTION
service nova-conductor $ACTION
service nova-novncproxy $ACTION
service nova-compute $ACTION

service neutron-server $ACTION
service openvswitch-switch $ACTION
service neutron-plugin-openvswitch-agent $ACTION
service neutron-l3-agent $ACTION
service neutron-dhcp-agent $ACTION
service neutron-metadata-agent $ACTION

service cinder-scheduler $ACTION
service cinder-api $ACTION
service cinder-volume $ACTION
service tgt $ACTION

service heat-api $ACTION
service heat-api-cfn $ACTION
service heat-engine $ACTION
