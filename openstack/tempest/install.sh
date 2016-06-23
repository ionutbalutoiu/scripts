#!/usr/bin/env bash
set -e

sudo add-apt-repository cloud-archive:mitaka -y
sudo apt-get update
sudo apt-get install git python-pip libffi-dev libssl-dev libyaml-dev libpython2.7-dev python-subunit \
                     python-debtcollector python-dateutil python-oslo.context python-iso8601 python-monotonic \
                     python-fasteners -y

git clone http://git.openstack.org/openstack/tempest ~/tempest-git
sudo pip install ~/tempest-git

DIR=$(dirname $0)
pushd $HOME
tempest init hyper-c
cp $DIR/etc/tempest.conf hyper-c/etc/
cp $DIR/etc/accounts.yaml hyper-c/etc/
popd
