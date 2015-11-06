#!/usr/bin/env bash

if [[ $# -ne 2 ]]; then
    echo "USAGE: $0 <python_client_git_url>" \
                   "<git_branch>"
    exit 1
fi

URL="$1"
GIT_BRANCH="$2"
TMP_DIR="/tmp/`basename $URL`"

git clone $URL $TMP_DIR
pushd $TMP_DIR
git checkout $GIT_BRANCH
pip install -r requirements.txt
python setup.py install
popd
rm -rf $TMP_DIR
