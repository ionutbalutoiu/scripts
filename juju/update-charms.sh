#!/usr/bin/env bash
set -e

if [[ -z $JUJU_REPOSITORY ]]; then
    echo "ERROR: JUJU_REPOSITORY variable is not set."
    exit 1
fi

VERSION="$1"
if [[ $VERSION != "next" && $VERSION != "trunk" ]]; then
    echo "USAGE: $0 <next/trunk>"
    exit 1
fi
BRANCHES=`cat << EOF
lp:~charmers/charms/trusty/mysql/trunk
lp:~charmers/charms/trusty/rabbitmq-server/trunk
lp:~openstack-charmers/charms/trusty/glance/$VERSION
lp:~openstack-charmers/charms/trusty/keystone/$VERSION
lp:~openstack-charmers/charms/trusty/neutron-gateway/$VERSION
lp:~openstack-charmers/charms/trusty/neutron-api/$VERSION
lp:~openstack-charmers/charms/trusty/neutron-openvswitch/$VERSION
lp:~openstack-charmers/charms/trusty/nova-cloud-controller/$VERSION
lp:~openstack-charmers/charms/trusty/openstack-dashboard/$VERSION
lp:~openstack-charmers/charms/trusty/nova-compute/$VERSION
lp:~openstack-charmers/charms/trusty/swift-proxy/$VERSION
lp:~openstack-charmers/charms/trusty/swift-storage/$VERSION
EOF`

REPO="trusty-$VERSION"
for BRANCH in $BRANCHES; do
    CHARM=$(basename $(dirname $BRANCH))

    if [[ $VERSION = "next" ]]; then
        if [[ $CHARM == "mysql" || $CHARM == "rabbitmq-server" ]]; then
            # Skip RabbitMQ and MySQL if on the devel version of the charms
            continue
        fi
    fi

    if [[ -e $JUJU_REPOSITORY/$REPO/$CHARM ]]; then
        rm -rf $JUJU_REPOSITORY/$REPO/$CHARM
    fi

    echo "Branching $CHARM ..."
    bzr branch $BRANCH $JUJU_REPOSITORY/$REPO/$CHARM
done
