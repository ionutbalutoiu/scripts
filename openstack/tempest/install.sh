#!/usr/bin/env bash
set -e

sudo add-apt-repository cloud-archive:mitaka

sudo apt-get update
sudo apt-get install git python-pip libffi-dev libssl-dev libyaml-dev libpython2.7-dev python-subunit \
                     python-debtcollector python-dateutil python-oslo.context python-iso8601 python-monotonic \
                     python-fasteners


cd ~
sudo pip install virtualenv
virtualenv tempest-venv
source ./tempest-venv/bin/activate

git clone http://git.openstack.org/openstack/tempest /tmp/tempest
pip install /tmp/tempest
rm -rf /tmp/tempest

tempest init hyper-c
DIR=$(dirname $0)
cd hyper-c
cp $DIR/etc/tempest.conf ./etc/
cp $DIR/etc/accounts.yaml ./etc/
cp $DIR/excluded.txt ./
cp $DIR/run-all-tests.sh ./

echo "Created Hyper-C tempest venv. Please edit etc/tempest.conf and etc/accounts.yaml before running 'run-all-tests.sh'"
