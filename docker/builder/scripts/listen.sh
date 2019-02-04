#!/usr/bin/env bash

set -eu

LISTEN_PORT=${LISTEN_PORT:-"80"}
echo "info: running webserver on port ${LISTEN_PORT}"

while [ 1 ]; do
  # Listen for request
  PAYLOAD=$( nc -l -p ${LISTEN_PORT} -e ./validate-github-payload.sh 2>&1 ) || continue
  echo "info: received a valid request"
  echo $PAYLOAD | ./process-payload.sh
done
