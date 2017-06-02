#!/usr/bin/env bash

if [[ "$1" != "mitaka" ]] && [[ "$1" != "newton" ]] && [[ "$1" != "ocata" ]]; then
    echo "USAGE: $0 <mitaka/newton/ocata>"
    exit 1
fi

sudo apt install python-dev git -y

BRANCH="stable/$1"

pip install git+https://github.com/openstack/python-openstackclient.git@$BRANCH
pip install git+https://github.com/openstack/python-neutronclient.git@$BRANCH
pip install git+https://github.com/openstack/python-novaclient.git@$BRANCH
pip install git+https://github.com/openstack/python-glanceclient.git@$BRANCH
pip install git+https://github.com/openstack/python-cinderclient.git@$BRANCH
