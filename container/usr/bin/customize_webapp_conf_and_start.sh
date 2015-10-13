#!/usr/bin/env bash

# This script
# - sets nginx port config

# Exit immediately if a command exits with a non-zero status
set -e

# echo fn that outputs to stderr http://stackoverflow.com/a/2990533/511069
echoerr() {
  cat <<< "$@" 1>&2;
}

# print error and exit
die () {
  echoerr "ERROR: $0: $1"
  # if $2 is defined AND NOT EMPTY, use $2; otherwise, set to "150"
  errnum=${2-110}
  exit $errnum
}

# required
[ -z "${PACT_BROKER_PORT}" ] && die "Needs PACT_BROKER_PORT env var set"

echo "Set nginx port to ${PACT_BROKER_PORT}"
sed -i.bak "s/<broker_port>/${PACT_BROKER_PORT}/g" /etc/nginx/sites-enabled/webapp.conf
cat /etc/nginx/sites-enabled/webapp.conf
rm /etc/nginx/sites-enabled/webapp.conf.bak

# replace current shell via `exec` so signals are properly trapped
exec /sbin/my_init
