#!/usr/bin/env bash
set -euo pipefail

DIR=/vagrant/scripts

. ${DIR}/installers.sh

for conf in $(ls ${NGINX_CONF_DIR})
do
  [[ "$conf" == *".nginx" ]] && install_nginx_conf "$conf"
done

echo
echo "Nginx Status Test Results:"
nginx -t

echo
echo "Restarting Nginx..."
service nginx restart
