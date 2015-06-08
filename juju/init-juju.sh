set -e

rm -rf ~/.juju
juju init
mkdir -p ~/.juju/tools/releases
pushd ~/.juju/tools/releases
cp ~/golang/bin/jujud* .
TRUSTY_VERSION=`juju --version`
WIN_VERSION=`juju --version | sed "s/trusty/win2012r2/"`
tar -czf "juju-"$TRUSTY_VERSION".tgz" jujud
tar -czf "juju-"$WIN_VERSION".tgz" jujud.exe
rm jujud*
popd
juju-metadata generate-tools
sudo rm -rf /var/www/html/tools
sudo cp -rf ~/.juju/tools /var/www/html/
sudo chmod -R 777 /var/www/html/tools
cp ~/environments.yaml ~/.juju/
