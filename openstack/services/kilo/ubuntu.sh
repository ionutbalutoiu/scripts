if [ $# -ne 1 ]; then
    echo "USAGE: $0 <service_action>"
    exit 1
fi

for i in mysql rabbitmq-server apache2 glance-api glance-registry nova-api nova-cert nova-consoleauth nova-scheduler nova-conductor nova-novncproxy nova-compute neutron-server neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent openvswitch-switch neutron-plugin-openvswitch-agent cinder-scheduler cinder-api tgt cinder-volume heat-api heat-api-cfn heat-engine; do
    service $i $1
done

