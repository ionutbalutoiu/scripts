#!/bin/bash

if [[ $# -ne 3 ]]; then
	echo "USAGE: $0 <login_session> <name> <dd_file>"
	exit 1
fi

maas $1 boot-resources create name=$2 architecture=amd64/generic filetype=ddtgz content@=$3

# ./upload-image.sh root windows/win2012r2 /home/ubuntu/work/images/windows-win2012r2-with-update-amd64-root-dd
