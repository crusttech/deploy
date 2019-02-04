#!/usr/bin/env bash

set -eu

LISTEN_PORT=${LISTEN_PORT:-"80"}
echo "info: running webserver on port ${LISTEN_PORT}"

while [ 1 ]; do
  PAYLOAD_FILE=$(mktemp --suffix=-payload.json)
  # Listen for request
  PAYLOAD=$( nc -l -p ${LISTEN_PORT} -e ./validate-github-payload.sh $PAYLOAD_FILE ) || continue
  echo "info: received a valid request (dumped in ${PAYLOAD_FILE})"
  ./process-payload.sh $PAYLOAD_FILE
done
