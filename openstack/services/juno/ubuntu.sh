if [ $# -ne 1 ]; then
    echo "USAGE: $0 <service_action>"
    exit 1
fi

ACTION=$1

sudo service mysql $ACTION
sudo service rabbitmq-server $ACTION
#sudo service keystone $ACTION

sudo service glance-api $ACTION
sudo service glance-registry $ACTION

sudo service nova-api $ACTION
sudo service nova-cert $ACTION
sudo service nova-consoleauth $ACTION
sudo service nova-scheduler $ACTION
sudo service nova-conductor $ACTION
sudo service nova-novncproxy $ACTION
sudo service nova-compute $ACTION

sudo service neutron-server $ACTION
sudo service openvswitch-switch $ACTION
sudo service neutron-plugin-openvswitch-agent $ACTION
sudo service neutron-l3-agent $ACTION
sudo service neutron-dhcp-agent $ACTION
sudo service neutron-metadata-agent $ACTION

sudo service cinder-scheduler $ACTION
sudo service cinder-api $ACTION
sudo service cinder-volume $ACTION
sudo service tgt $ACTION

sudo service heat-api $ACTION
sudo service heat-api-cfn $ACTION
sudo service heat-engine $ACTION

sudo service memcached $ACTION
sudo service apache2 $ACTION
