#!/bin/bash

# GLOBAL PARAMETERS
IRONIC_CLIENT_GIT_URL="https://github.com/openstack/python-ironicclient.git"
IRONIC_INSPECTOR_CLIENT_GIT_URL="https://github.com/openstack/python-ironic-inspector-client.git"
GIT_BRANCH="stable/liberty"
###################

# Install ironic-client and ironic-inspector-client from git
for URL in $IRONIC_CLIENT_GIT_URL $IRONIC_INSPECTOR_CLIENT_GIT_URL; do
    TMP_DIR="/tmp/`basename $URL`"
    git clone $URL $TMP_DIR
    pushd $TMP_DIR
    git checkout $GIT_BRANCH
    pip install -r requirements.txt
    python setup.py install
    popd
    rm -rf $TMP_DIR
done
