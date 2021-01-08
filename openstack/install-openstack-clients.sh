#!/usr/bin/env bash
set -e

if [[ $# -ne 1 ]]; then
    echo "USAGE: $0 <release_name>"
    exit 1
fi

BRANCH="stable/$1"

pip3 install git+https://github.com/openstack/python-openstackclient.git@$BRANCH
pip3 install git+https://github.com/openstack/python-neutronclient.git@$BRANCH
pip3 install git+https://github.com/openstack/python-novaclient.git@$BRANCH
pip3 install git+https://github.com/openstack/python-glanceclient.git@$BRANCH
pip3 install git+https://github.com/openstack/python-cinderclient.git@$BRANCH
pip3 install git+https://github.com/openstack/python-heatclient.git@$BRANCH
pip3 install git+https://github.com/openstack/python-magnumclient.git@$BRANCH
