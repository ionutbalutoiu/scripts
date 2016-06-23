#!/bin/bash

DIR=$(dirname $0)
DATE=$(date | sed "s| |_|g" | sed "s|:|_|g")

pushd $DIR
echo "Generating tests list"
testr list-tests > full-tests-list.txt 2>/dev/null
egrep -vf excluded.txt full-tests-list.txt > run-tests-list.txt
rm full-tests-list.txt
testr run --subunit --load-list="run-tests-list.txt" > results.txt
rm run-tests-list.txt
subunit2html results.txt
rm results.txt

RESULTS_DIR="/var/www/html/results"
if [[ ! -d $RESULTS_DIR ]]; then
    sudo mkdir $RESULTS_DIR
fi
popd
mv results.html $RESULTS_DIR/results_${DATE}.html 
