#!/usr/bin/env bash

VAGRANT_DIR=${VAGRANT_DIR:-/vagrant}
NGINX_CONF_DIR=${VAGRANT_DIR}/conf/nginx

install_nginx_conf() {
  local enabledir=/etc/nginx/sites-enabled
  local nginxdir=/etc/nginx/sites-available
  local srcdir=${NGINX_CONF_DIR}

  local enabled="$enabledir/${1%.nginx}"
  local dest="$nginxdir/${1%.nginx}"
  local conf="$srcdir/$1"
  local retval

  set +e
  cmp -s "$conf" "$dest"
  retval=$?
  set -e

  if [ ${retval} -eq 0 ];
  then
    echo "$1 is already installed. Checking if enabled..."
  else
    echo "Attempting to install Nginx configuration: $1"
    echo "* Copying $conf to $dest"
    [ -f "$dest" ] && rm "$dest"
    cp "$conf" "$dest"
  fi

  [ -f "$enabled" ] && echo "* Already enabled." || { echo "* Enabling $dest"; ln -s "$dest" "$enabled"; }

  echo "* $1 done!"
}
