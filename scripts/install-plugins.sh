#!/usr/bin/env bash
set -euo pipefail

DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
logfile="${DIR}/log/install-plugins.log"
plugins_file="${DIR}/../plugins"

. ${DIR}/include.sh

init_log

installed=$(vagrant plugin list)
plugins=$(cat "${plugins_file}")

for plugin in ${plugins}; do
  plugin=$(echo "$plugin" | xargs)

  set +e
  check=$(echo "$installed" | grep "$plugin" | xargs)
  set -e

  if [ "$plugin" != "" ] && [ -z "$check" ]; then
    step "${plugin} plugin" vagrant plugin install "${plugin}"
  elif [ ! -z "$check" ]; then
    step "${plugin} already installed" echo "Skipping ${plugin}"
  fi
done
