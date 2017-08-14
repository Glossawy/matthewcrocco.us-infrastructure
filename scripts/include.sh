#!/usr/bin/env bash
set -euo pipefail

WHITE='\e[97m' GREEN='\e[32m' RED='\e[91m' YELLOW='\e[33m' RESET='\e[0m'

for option in "${@}"; do
  case ${option} in
    -nc|--no-color) WHITE= GREEN= RED= YELLOW= RESET= ;;
  esac
done

cecho() {
  echo -e "${@}${RESET}"
}

init_log() {
  [ ${logfile:-x} == 'x' ] && return 1
  rm "$logfile"
  touch "$logfile"
}

log_exec() {
  [ ${logfile:-x} == 'x' ] && "${@}" &> /dev/null || "${@}" &>> ${logfile}
}

check_status() {
  if [ $? -eq 0 ]; then
    cecho "${GREEN}✔ OK"
  else
    cecho "${RED}✘ FAIL"
    cecho "${YELLOW}Check ${logfile##*/} for error information."
    exit
  fi
}

step() {
  local msg="$1"; shift
  printf "${WHITE}${msg}... "

  set +e
  log_exec "${@}"
  check_status
  set -e
}

random_hexstring() {
  hexdump -n 16 -e '4/4 "%08X" 1 "\n"' /dev/random | tr '[:upper:]' '[:lower:]'
}

vagrant_run() {
  local power=$(vagrant status | grep "(virtualbox)$" | awk '{print $2}')
  local password=$(random_hexstring)
  echo ":: Using VAGRANT_PG_PASSWORD=${password}"

  if [ "$power" == "running" ]; then
    if [[ "${1:-}" == "reload" ]]
    then
      echo ":: Rebooting vagrant VM"
      VAGRANT_PG_PASSWORD=${password} vagrant reload --provision
      RESULT=$?
    else
      echo ":: Running vagrant provisioner"
      VAGRANT_PG_PASSWORD=${password} vagrant provision
      RESULT=$?
    fi
  else
    echo ":: Starting vagrant VM"
    VAGRANT_PG_PASSWORD=${password} vagrant up --provision
    RESULT=$?
  fi
  if [ $RESULT -ne 0 ]
  then
    echo "!! vagrant provision failed. Rerun or report incident."
    echo "!!"
    echo "!! If the puppet provisioner is the cause, this can leave the vagrant box without full configuration"
  fi
}
