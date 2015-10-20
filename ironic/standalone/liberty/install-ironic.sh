#!/bin/bash

if [[ $# -ne 2 ]]; then
    echo "USAGE: $0 <Password> <Private_IP>"
    exit 1
fi

# GLOBAL PARAMETERS
PASSWORD="$1" # Password used by MySQL and RabbitMQ
IRONIC_PRIVATE_IP="$2"
GIT_BRANCH="stable/liberty"
IRONIC_DIRS="/etc/ironic /var/lib/ironic /var/log/ironic"
IRONIC_USER="ironic"
IRONIC_GIT_URL="https://github.com/openstack/ironic.git"
IRONIC_TMP="/tmp/ironic-git"
IRONIC_CLIENT_GIT_URL="https://github.com/openstack/python-ironicclient.git"
IRONIC_CLIENT_TMP="/tmp/ironic-client-git"
KEYSTONERC="/root/keystonerc"
ENABLED_DRIVERS="agent_ipmitool,pxe_ipmitool,agent_ssh"
DEBUG_MODE="True"
VERBOSE_MODE="True"
###################

# Enable Liberty repository
apt-get install ubuntu-cloud-keyring --force-yes -y
add-apt-repository cloud-archive:liberty -y

# Install dependencies (MySQL database, RabbitMQ server, etc)
apt-get update
apt-get install crudini qemu open-iscsi rabbitmq-server ipmitool git \
                python-pip tftpd-hpa tftp-hpa nginx syslinux-common \
                syslinux ipxe python-dev libxml2-dev libxslt1-dev zlib1g-dev -y
DEBIAN_FRONTEND=noninteractive apt-get install mysql-server -y -q

# Install Ironic from git
grep $IRONIC_USER /etc/passwd -q || useradd $IRONIC_USER
for i in $IRONIC_DIRS; do mkdir -p $i; done
git clone $IRONIC_GIT_URL $IRONIC_TMP
pushd $IRONIC_TMP
git checkout $GIT_BRANCH
pip install -r requirements.txt
python setup.py install
cp -rf etc/ironic/* /etc/ironic/
mv /etc/ironic/ironic.conf.sample /etc/ironic/ironic.conf
for i in $IRONIC_DIRS; do chown -R $IRONIC_USER:$IRONIC_USER $i; done
popd
rm -rf $IRONIC_TMP

# Install python-ironic-client from git
git clone $IRONIC_CLIENT_GIT_URL $IRONIC_CLIENT_TMP
pushd $IRONIC_CLIENT_TMP
git checkout $GIT_BRANCH
pip install -r requirements.txt
python setup.py install
popd
rm -rf $IRONIC_CLIENT_TMP

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

exec start-stop-daemon --start -c $IRONIC_USER --exec /usr/local/bin/ironic-api -- --config-file /etc/ironic/ironic.conf --log-file /var/log/ironic/ironic-api.log
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

exec start-stop-daemon --start -c $IRONIC_USER --exec /usr/local/bin/ironic-conductor -- --config-file /etc/ironic/ironic.conf --log-file /var/log/ironic/ironic-conductor.log
EOF

# Generate ironic.conf file
cat << EOF > /etc/ironic/ironic.conf
[DEFAULT]
log_dir = /var/log/ironic
auth_strategy = noauth
enabled_drivers = $ENABLED_DRIVERS
debug = $DEBUG_MODE
verbose = $VERBOSE_MODE

[conductor]
api_url = http://$IRONIC_PRIVATE_IP:6385
clean_nodes = false

[api]
host_ip = 0.0.0.0
port = 6385

[database]
connection = mysql+pymysql://ironic:$PASSWORD@127.0.0.1/ironic?charset=utf8

[dhcp]
dhcp_provider = none

[glance]
auth_strategy = noauth

[neutron]
auth_strategy = noauth

[pxe]
tftp_root = /tftpboot
tftp_server = $IRONIC_PRIVATE_IP
ipxe_enabled = True
pxe_bootfile_name = undionly.kpxe
pxe_config_template = \$pybasedir/drivers/modules/ipxe_config.template

[deploy]
http_root = /httpboot
http_url = http://$IRONIC_PRIVATE_IP:8080

[oslo_messaging_rabbit]
rabbit_userid = openstack
rabbit_password = $PASSWORD
EOF

# Set up RabbitMQ user
rabbitmqctl add_user openstack $PASSWORD
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

# MySQL installation and database creation
mysqladmin -u root password $PASSWORD
if [[ $? -ne 0 ]]; then
    mysql -u root -p"$PASSWORD" -e "" &> /dev/null
    if [[ $? -ne 0 ]]; then
        echo "ERROR: MySQL root password already set and it differs from the current one."
        exit 1
    fi
fi
mysql -u root -p"$PASSWORD" -e "USE ironic;" &> /dev/null
if [[ $? -eq 0 ]]; then
    mysql -u root -p"$PASSWORD" -e "DROP DATABASE ironic;"
fi
mysql -u root -p"$PASSWORD" -e "CREATE DATABASE ironic CHARACTER SET utf8;"
mysql -u root -p"$PASSWORD" -e "GRANT ALL PRIVILEGES ON ironic.* TO 'ironic'@'localhost' IDENTIFIED BY '$PASSWORD';"
mysql -u root -p"$PASSWORD" -e "GRANT ALL PRIVILEGES ON ironic.* TO 'ironic'@'%' IDENTIFIED BY '$PASSWORD';"

# Create Ironic database tables
pip install pymysql
ironic-dbsync --config-file /etc/ironic/ironic.conf upgrade

# Set up the TFTP to serve iPXE
mkdir -p /tftpboot
mkdir -p /httpboot
cp /usr/lib/syslinux/pxelinux.0 /tftpboot
cp /usr/lib/syslinux/chain.c32 /tftpboot
cp /usr/lib/ipxe/undionly.kpxe /tftpboot

echo 'r ^([^/]) /tftpboot/\1' > /tftpboot/map-file
echo 'r ^(/tftpboot/) /tftpboot/\2' >> /tftpboot/map-file

cat << EOF > /etc/default/tftpd-hpa
TFTP_USERNAME="$IRONIC_USER"
TFTP_DIRECTORY="/tftpboot"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="-v -v -v -v -v --map-file /tftpboot/map-file /tftpboot"
EOF

chown -R $IRONIC_USER:$IRONIC_USER /tftpboot
chown -R $IRONIC_USER:$IRONIC_USER /httpboot
service tftpd-hpa restart

# Set up Nginx web server for images deployed by Ironic
mkdir -p /ironic_images
cat << EOF > /etc/nginx/sites-available/default
server {
    listen 80;
    root /ironic_images;
    server_name default;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

cat << EOF > /etc/nginx/sites-available/httpboot
server {
    listen 8080;
    root /httpboot;
    server_name httpboot;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
ls /etc/nginx/sites-enabled/httpboot &>/dev/null || ln -s /etc/nginx/sites-available/httpboot /etc/nginx/sites-enabled
service nginx reload

# Create keystonerc file
cat << EOF > $KEYSTONERC
export OS_AUTH_TOKEN=' '
export IRONIC_URL=http://$IRONIC_PRIVATE_IP:6385/
EOF

# Create Ironic sudoers file
cat << EOF > /etc/sudoers.d/ironic_sudoers
Defaults:ironic !requiretty

ironic ALL = (root) NOPASSWD: /usr/local/bin/ironic-rootwrap /etc/ironic/rootwrap.conf *
EOF

# Restart the Ironic services
for i in ironic-api ironic-conductor; do service $i restart; done
