#!/usr/bin/env bash
set -e

if [[ $# -ne 2 ]]; then
    echo "USAGE: $0 <python_client_git_url>" \
                   "<git_branch>"
    exit 1
fi

URL="$1"
GIT_BRANCH="$2"
TMP_DIR="/tmp/`basename $URL`"

if [[ -e $TMP_DIR ]]; then
    rm -rf $TMP_DIR
fi

git clone $URL $TMP_DIR -b $GIT_BRANCH
pushd $TMP_DIR
pip install -r requirements.txt
python setup.py install
popd
rm -rf $TMP_DIR
