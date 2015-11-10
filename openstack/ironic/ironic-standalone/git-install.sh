#!/usr/bin/env bash
set -e

if [[ $# -ne 12 ]]; then
    echo "USAGE: $0 <ironic_user>" \
                   "<ironic_git_url>" \
                   "<git_branch>" \
                   "<ironic_private_ip>" \
                   "<enabled_drivers>" \
                   "<ironic_db_name>" \
                   "<ironic_db_user>" \
                   "<ironic_db_user_password>" \
                   "<tftp_root>" \
                   "<http_root>" \
                   "<rabbitmq_user_password>" \
                   "<ironic_images_dir>"
    exit 1
fi

# GLOBAL PARAMETERS
IRONIC_USER="$1"
IRONIC_GIT_URL="$2"
GIT_BRANCH="$3"
IRONIC_PRIVATE_IP="$4"
ENABLED_DRIVERS="$5"
DB_NAME="$6"
DB_USER="$7"
DB_USER_PASSWORD="$8"
TFTP_ROOT="$9"
HTTP_ROOT="${10}"
RABBITMQ_USER_PASSWORD="${11}"
IRONIC_IMAGES_DIR="${12}"
ETC_DIR="/etc/ironic"
LIB_DIR="/var/lib/ironic"
LOG_DIR="/var/log/ironic"
###################

# Install Ironic from git
grep $IRONIC_USER /etc/passwd -q || useradd $IRONIC_USER
for i in $ETC_DIR $LIB_DIR $LOG_DIR; do
    mkdir -p $i;
done
TMP_DIR="/tmp/`basename $IRONIC_GIT_URL`"
git clone $IRONIC_GIT_URL $TMP_DIR -b $GIT_BRANCH
pushd $TMP_DIR
pip install -r requirements.txt
python setup.py install
cp -rf etc/ironic/* $ETC_DIR
mv $ETC_DIR/ironic.conf.sample /etc/ironic/ironic.conf
popd
for i in $ETC_DIR $LIB_DIR $LOG_DIR; do
    chown -R $IRONIC_USER:$IRONIC_USER $i
done
rm -rf $TMP_DIR

# Generate ironic.conf file
$(dirname $0)/liberty/conf.sh \
    $ENABLED_DRIVERS \
    $IRONIC_PRIVATE_IP \
    $DB_NAME \
    $DB_USER \
    $DB_USER_PASSWORD \
    $TFTP_ROOT \
    $HTTP_ROOT \
    $RABBITMQ_USER_PASSWORD

# Create Ironic database tables
pip install pymysql
ironic-dbsync --config-file $ETC_DIR/ironic.conf upgrade

# Set up the TFTP to serve iPXE
mkdir -p $TFTP_ROOT
mkdir -p $HTTP_ROOT
cp /usr/lib/syslinux/pxelinux.0 $TFTP_ROOT
cp /usr/lib/syslinux/chain.c32 $TFTP_ROOT
cp /usr/lib/ipxe/undionly.kpxe $TFTP_ROOT

echo 'r ^([^/]) /tftpboot/\1' > $TFTP_ROOT/map-file
echo 'r ^(/tftpboot/) /tftpboot/\2' >> $TFTP_ROOT/map-file

cat << EOF > /etc/default/tftpd-hpa
TFTP_USERNAME="$IRONIC_USER"
TFTP_DIRECTORY="$TFTP_ROOT"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--map-file $TFTP_ROOT/map-file $TFTP_ROOT"
EOF

chown -R $IRONIC_USER:$IRONIC_USER $TFTP_ROOT
chown -R $IRONIC_USER:$IRONIC_USER $HTTP_ROOT
service tftpd-hpa restart

# Set up Nginx web server for images deployed by Ironic
mkdir -p $IRONIC_IMAGES_DIR
cat << EOF > /etc/nginx/sites-available/default
server {
    listen 80;
    root $IRONIC_IMAGES_DIR;
    server_name default;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

cat << EOF > /etc/nginx/sites-available/httpboot
server {
    listen 8080;
    root $HTTP_ROOT;
    server_name httpboot;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
ls /etc/nginx/sites-enabled/httpboot &>/dev/null || ln -s /etc/nginx/sites-available/httpboot /etc/nginx/sites-enabled
service nginx reload

# Create Ironic sudoers file
cat << EOF > /etc/sudoers.d/ironic_sudoers
Defaults:$IRONIC_USER !requiretty

$IRONIC_USER ALL = (root) NOPASSWD: /usr/local/bin/ironic-rootwrap $ETC_DIR/rootwrap.conf *
EOF

# Create ironic-api upstart service
cat << EOF > /etc/init/ironic-api.conf
start on runlevel [2345]
stop on runlevel [016]
pre-start script
  mkdir -p /var/run/ironic
  chown -R $IRONIC_USER:$IRONIC_USER /var/run/ironic
end script
respawn
respawn limit 2 10

exec start-stop-daemon --start -c $IRONIC_USER --exec /usr/local/bin/ironic-api -- --config-file $ETC_DIR/ironic.conf --log-file $LOG_DIR/ironic-api.log
EOF

# Create ironic-conductor upstart service
cat << EOF > /etc/init/ironic-conductor.conf
start on runlevel [2345]
stop on runlevel [016]
pre-start script
  mkdir -p /var/run/ironic
  chown -R $IRONIC_USER:$IRONIC_USER /var/run/ironic
end script
respawn
respawn limit 2 10

exec start-stop-daemon --start -c $IRONIC_USER --exec /usr/local/bin/ironic-conductor -- --config-file $ETC_DIR/ironic.conf --log-file $LOG_DIR/ironic-conductor.log
EOF

# Restart the Ironic services
for i in ironic-api ironic-conductor; do
    service $i restart
done
