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
