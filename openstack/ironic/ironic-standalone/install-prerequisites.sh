#!/usr/bin/env bash
set -e

# Install prerequisites (MySQL database, RabbitMQ server, etc)
apt-get update
apt-get install crudini qemu open-iscsi rabbitmq-server ipmitool git kpartx \
                python-pip tftpd-hpa tftp-hpa nginx syslinux-common \
                syslinux ipxe python-dev libxml2-dev libxslt1-dev zlib1g-dev genisoimage -y
DEBIAN_FRONTEND=noninteractive apt-get install mysql-server -y -q
