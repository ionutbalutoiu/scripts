#!/usr/bin/env bash
set -e

if [[ -z $GOPATH ]]; then
    echo "ERROR: GOPATH was not set."
fi

JUJU_HOME=~/.local/share/juju

pushd $GOPATH/src/github.com/juju/juju
godeps -f -u dependencies.tsv
popd

go install -v github.com/juju/juju/...
GOOS=windows go install -v github.com/juju/juju/...

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

for i in trusty centos7 xenial; do
    tar -czf "juju-$BASE_NAME-$i-${ARCH}.tgz" jujud
done
rm jujud

for i in win2008r2 win2012 win2012hv win2012r2 win10 win2012hvr2 win2016 win2016nano; do
    tar -czf "juju-$BASE_NAME-$i-${ARCH}.tgz" jujud.exe
done
rm jujud.exe

popd

juju-metadata generate-tools --stream devel

echo "Copying tools to /var/www/html/tools"
sudo rm -rf /var/www/html/tools
sudo cp -rf $JUJU_HOME/tools /var/www/html
sudo chmod 755 -R /var/www/html/tools
