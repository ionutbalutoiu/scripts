#!/usr/bin/env bash

if [[ $# -ne 5 ]]; then
    echo "USAGE: $0 <mysql_db_host>" \
                   "<mysql_root_password>" \
                   "<mysql_db_name>" \
                   "<mysql_db_user>" \
                   "<mysql_db_user_password>"
    exit 1
fi

MYSQL_HOST="$1"
MYSQL_ROOT_PASSWORD="$2"
MYSQL_DB_NAME="$3"
MYSQL_DB_USER="$4"
MYSQL_DB_USER_PASSWORD="$5"

mysql -h "$MYSQL_HOST" -u root -p"$MYSQL_ROOT_PASSWORD" -e "USE $MYSQL_DB_NAME;" &> /dev/null
if [[ $? -eq 0 ]]; then
    mysql -h "$MYSQL_HOST" -u root -p"$MYSQL_ROOT_PASSWORD" -e "DROP DATABASE $MYSQL_DB_NAME;"
fi
mysql -h "$MYSQL_HOST" -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE $MYSQL_DB_NAME CHARACTER SET utf8;"
mysql -h "$MYSQL_HOST" -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON ${MYSQL_DB_NAME}.* TO '$MYSQL_DB_USER'@'localhost' IDENTIFIED BY '$MYSQL_DB_USER_PASSWORD';"
mysql -h "$MYSQL_HOST" -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON ${MYSQL_DB_NAME}.* TO '$MYSQL_DB_USER'@'%' IDENTIFIED BY '$MYSQL_DB_USER_PASSWORD';"
