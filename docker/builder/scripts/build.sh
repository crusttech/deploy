#!/usr/bin/env bash

set -eu

case ${1:-""} in
  crust|api)
    ./build-api-image.sh $@
    ;;
  webapp-*)
    ./build-webapp-image.sh $@
    ;;
  *)
    echo "error: unsupported build"
    exit 1;
    ;;
esac
