#!/usr/bin/env bash
set -e


if [[ $# -lt 2 ]]; then
    echo "$0 <charm_dir> <module_1> <module_2> ..."
    exit 1
fi

TMP_DIR="/tmp/juju-charm-layers-$(date | md5sum | awk '{print $1}')"
git clone git@bitbucket.org:ionutbalutoiu/charm-layers.git $TMP_DIR --recursive

CHARM_DIR=$1
shift

while [[ $# -gt 0 ]]; do
    if [[ -e "$CHARM_DIR/lib/Modules/$1" ]]; then
        rm -rf "$CHARM_DIR/lib/Modules/$1"
    fi
    cp -rf $TMP_DIR/$1 "$CHARM_DIR/lib/Modules/$1"
    shift
done

rm -rf $TMP_DIR
