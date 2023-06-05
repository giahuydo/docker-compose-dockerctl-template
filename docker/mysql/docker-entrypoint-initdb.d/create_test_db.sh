#!/usr/bin/env sh
echo "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}_test\` ;" | mysql -uroot -p${MYSQL_ROOT_PASSWORD}
echo "GRANT ALL ON \`${MYSQL_DATABASE}_test\`.* TO '${MYSQL_USER}'@'%';" | mysql -uroot -p${MYSQL_ROOT_PASSWORD}