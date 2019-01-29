#!/usr/bin/env bash

set -eu

while [ 1 ]; do
  nc -l -p ${LISTEN_PORT:-"80"} -e ./webhook-handler.sh || continue
  ./entrypoint.sh $@
done
