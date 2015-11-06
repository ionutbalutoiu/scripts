#!/usr/bin/env bash
set -e

if [[ $# -ne 5 ]]; then
    echo "USAGE: $0 <ironic_inspector_git_url>" \
                   "<git_branch>" \
                   "<ironic_user>" \
                   "<ironic_etc_dir>" \
                   "<ironic_log_dir>"
    exit 1
fi

IRONIC_INSPECTOR_GIT_URL="$1"
GIT_BRANCH="$2"
IRONIC_USER="$3"
IRONIC_INSPECTOR_ETC="$4"
IRONIC_INSPECTOR_LOG="$5"

# Install ironic-inspector from git
grep $IRONIC_USER /etc/passwd -q || useradd $IRONIC_USER

for i in $IRONIC_INSPECTOR_ETC $IRONIC_INSPECTOR_LOG; do
    mkdir -p $i
    chown -R $IRONIC_USER:$IRONIC_USER $i;
done

TMP_DIR="/tmp/`basename $IRONIC_INSPECTOR_GIT_URL`"
git clone $IRONIC_INSPECTOR_GIT_URL $TMP_DIR -b $GIT_BRANCH
pushd $TMP_DIR
pip install -r requirements.txt
python setup.py install

cp -rf rootwrap.conf rootwrap.d $IRONIC_INSPECTOR_ETC
chown root:root -R $IRONIC_INSPECTOR_ETC/rootwrap.conf $IRONIC_INSPECTOR_ETC/rootwrap.d
popd
rm -rf $TMP_DIR


# Add ironic-inspector to sudoers
cat << EOF > /etc/sudoers.d/ironic_inspector_sudoers
Defaults:$IRONIC_USER !requiretty

$IRONIC_USER ALL = (root) NOPASSWD: /usr/local/bin/ironic-inspector-rootwrap $IRONIC_INSPECTOR_ETC/rootwrap.conf *
EOF

# Create database tables
ironic-inspector-dbsync --config-file $IRONIC_INSPECTOR_ETC/inspector.conf upgrade

# Create ironic-inspector upstart service
cat << EOF > /etc/init/ironic-inspector.conf
start on runlevel [2345]
stop on runlevel [016]
pre-start script
  mkdir -p /var/run/ironic
  chown -R $IRONIC_USER:$IRONIC_USER /var/run/ironic
end script
respawn
respawn limit 2 10

exec start-stop-daemon --start -c $IRONIC_USER --exec /usr/local/bin/ironic-inspector -- --config-file $IRONIC_INSPECTOR_ETC/inspector.conf --log-file $IRONIC_INSPECTOR_LOG/ironic-inspector.log
EOF

# Start service
service ironic-inspector restart
