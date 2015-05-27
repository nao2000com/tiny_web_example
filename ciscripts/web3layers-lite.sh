#!/bin/bash
#
#
set -e
set -o pipefail
set -u

# required shell params

: "${YUM_HOST:?"should not be empty"}"

#

cd ${BASH_SOURCE[0]%/*}/wakame-vdc

# run instances

eval "$(
  ${BASH_SOURCE[0]%/*}/setup-db.sh
)"

eval "$(
  YUM_HOST="${YUM_HOST}" DB_HOST="${DB_HOST}" \
  ${BASH_SOURCE[0]%/*}/setup-app.sh
)"

## trap

trap '
 mussel instance destroy "${DB_ID}"
 mussel instance destroy "${APP_ID}"
' ERR EXIT

# smoketest

## app

#if [[ -n "${JENKINS_HOME:-""}" ]]; then
#  # called by jenkins
#  # TODO
#  echo not implemented so far.
#else
  # stand alone
  APP_HOST="${APP_HOST}" ${BASH_SOURCE[0]%/*}/smoketest-app.sh
  WEB_HOST="${APP_HOST}" ${BASH_SOURCE[0]%/*}/smoketest-web.sh
#fi
