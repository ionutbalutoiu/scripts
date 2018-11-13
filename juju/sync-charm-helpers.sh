#!/usr/bin/env bash
set -e


if [[ $# -lt 2 ]]; then
    echo "$0 <charm_dir> <module_1> <module_2> ..."
    exit 1
fi

TMP_DIR="/tmp/juju-powershell-modules-$(date | md5sum | awk '{print $1}')"
git clone https://github.com/cloudbase/juju-powershell-modules.git $TMP_DIR --recursive

CHARM_DIR=$1
shift

while [[ $# -gt 0 ]]; do
    if [[ -e "$CHARM_DIR/lib/Modules/$1" ]]; then
        rm -rf "$CHARM_DIR/lib/Modules/$1"
    fi
    cp -rf $TMP_DIR/$1 "$CHARM_DIR/lib/Modules/$1"
    rm -rf "$CHARM_DIR/lib/Modules/$1/.git"
    shift
done

rm -rf $TMP_DIR
