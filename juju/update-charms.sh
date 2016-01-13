#!/usr/bin/env bash
set -e

if [[ -z $JUJU_REPOSITORY ]]; then
    echo "Please set JUJU_REPOSITORY environment variable."
    exit 1
fi

if [[ $# -ne 1 ]]; then
    echo "USAGE: $0 <series>"
    echo "Valid series: 'trusty/trunk', 'trusty/next'"
    exit 1
fi

TRUNK_BRANCHES=(
    "lp:charms/trusty/glance"
    "lp:charms/trusty/keystone"
    "lp:charms/trusty/mysql"
    "lp:charms/trusty/neutron-api"
    "lp:charms/neutron-gateway"
    "lp:charms/trusty/neutron-openvswitch"
    "lp:charms/trusty/nova-cloud-controller"
    "lp:charms/trusty/nova-compute"
    "lp:charms/trusty/openstack-dashboard"
    "lp:charms/trusty/rabbitmq-server"
    "lp:charms/trusty/swift-proxy"
    "lp:charms/trusty/swift-storage"
    "lp:~cloudbaseit/charms/trusty/ironic/trunk"
    "lp:~cloudbaseit/charms/trusty/nova-compute-ironic/trunk"
    "lp:~juju-gui/charms/trusty/juju-gui/trunk"
)

NEXT_BRANCHES=(
    "lp:~openstack-charmers/charms/trusty/glance/next"
    "lp:~openstack-charmers/charms/trusty/keystone/next"
    "lp:~openstack-charmers/charms/trusty/neutron-api/next"
    "lp:~openstack-charmers/charms/trusty/neutron-gateway/next"
    "lp:~openstack-charmers/charms/trusty/neutron-openvswitch/next"
    "lp:~openstack-charmers/charms/trusty/nova-cloud-controller/next"
    "lp:~openstack-charmers/charms/trusty/nova-compute/next"
    "lp:~openstack-charmers/charms/trusty/openstack-dashboard/next"
    "lp:~openstack-charmers/charms/trusty/swift-proxy/next"
    "lp:~openstack-charmers/charms/trusty/swift-storage/next"
)

SERIES="$1"
if [[ "$SERIES" = "trusty/trunk" ]]; then
    for i in `seq 0 14`; do
        BRANCH=${TRUNK_BRANCHES[$i]}
        BASE_NAME=$(basename $BRANCH)
        if [[ "$BASE_NAME" = "trunk" ]]; then
            CHARM_NAME=$(basename $(dirname $BRANCH))
            CHARM_DIR="$JUJU_REPOSITORY/trusty-trunk/$CHARM_NAME"
        else
            CHARM_NAME=$(basename $BRANCH)
            CHARM_DIR="$JUJU_REPOSITORY/trusty-trunk/$CHARM_NAME"
        fi
        echo "Updating $CHARM_NAME"
        [[ -e $CHARM_DIR ]] && rm -rf $CHARM_DIR
        bzr branch $BRANCH $CHARM_DIR
    done
elif [[ "$SERIES" = "trusty/next" ]]; then
    for i in `seq 0 9`; do
        BRANCH=${NEXT_BRANCHES[$i]}
        CHARM_NAME=$(basename $(dirname $BRANCH))
        CHARM_DIR="$JUJU_REPOSITORY/trusty-next/$CHARM_NAME"
        echo "Updating $CHARM_NAME"
        [[ -e $CHARM_DIR ]] && rm -rf $CHARM_DIR
        bzr branch $BRANCH $CHARM_DIR
    done
else
    echo "ERROR: Invalid series was given."
    exit 1
fi
