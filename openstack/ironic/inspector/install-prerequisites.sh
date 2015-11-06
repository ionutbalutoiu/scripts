#!/usr/bin/env bash
set -e

apt-get install git dnsmasq python-pip python-dev syslinux-common syslinux -y
pip install pymysql
