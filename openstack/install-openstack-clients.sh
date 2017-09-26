#!/usr/bin/env bash

if [[ "$1" != "pike" ]] && [[ "$1" != "newton" ]] && [[ "$1" != "ocata" ]]; then
    echo "USAGE: $0 <newton/ocata/pike>"
    exit 1
fi

APPS="gcc python-dev"
echo "Need sudo password to install: $APPS"
sudo apt install $APPS -y

BRANCH="stable/$1"

pip install git+https://github.com/openstack/python-openstackclient.git@$BRANCH
pip install git+https://github.com/openstack/python-neutronclient.git@$BRANCH
pip install git+https://github.com/openstack/python-novaclient.git@$BRANCH
pip install git+https://github.com/openstack/python-glanceclient.git@$BRANCH
pip install git+https://github.com/openstack/python-cinderclient.git@$BRANCH
pip install git+https://github.com/openstack/python-heatclient.git@$BRANCH
pip install git+https://github.com/openstack/python-magnumclient.git@$BRANCH
