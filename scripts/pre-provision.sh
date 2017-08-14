#!/usr/bin/env bash
set -euo pipefail

if [[ ! "$(cat /etc/resolvconf/resolv.conf.d/base)" == *"nameserver 8.8.8.8"* ]]
then
  echo "Adding Google DNS Server to resolv base"
  echo "nameserver 8.8.8.8" | tee /etc/resolvconf/resolv.conf.d/base > /dev/null
fi

echo "Restarting resolvconf"
service resolvconf restart

echo "Pre-provision Done!"
