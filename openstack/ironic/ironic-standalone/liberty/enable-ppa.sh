#!/usr/bin/env bash
set -e

# Enable Liberty repository
apt-get install ubuntu-cloud-keyring --force-yes -y
add-apt-repository cloud-archive:liberty -y
apt-get update
