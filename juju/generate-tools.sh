#!/usr/bin/env bash
set -e

if [[ -z $GOPATH ]]; then
    echo "ERROR: GOPATH was not set."
fi

sudo apt-get install golang-go-windows-amd64 -y

pushd $GOPATH/src/github.com/juju/juju
godeps -f -u dependencies.tsv
popd
go install -v github.com/juju/juju/...
GOOS=windows go install -v github.com/juju/juju/...

# New JUJU_HOME from Juju 2.0
JUJU_HOME=~/.local/share/juju

rm -rf $JUJU_HOME/tools
mkdir -p $JUJU_HOME/tools/devel
pushd $JUJU_HOME/tools/devel
cp $GOPATH/bin/jujud ./
cp $GOPATH/bin/windows_amd64/jujud.exe ./

IFS='-' read -r -a VERS <<< "`juju --version`"
if [[ ${#VERS[@]} -eq 4 ]]; then
    BASE_NAME="${VERS[0]}-${VERS[1]}"
    ARCH="${VERS[3]}"
else
    BASE_NAME="${VERS[0]}"
    ARCH="${VERS[2]}"
fi

for i in trusty centos7; do
    tar -czf "juju-$BASE_NAME-$i-${ARCH}.tgz" jujud
done
rm jujud

for i in win2012r2 win10 win2012hvr2 win2016 win2016nano; do
    tar -czf "juju-$BASE_NAME-$i-${ARCH}.tgz" jujud.exe
done
rm jujud.exe

popd
juju-metadata generate-tools --stream devel
