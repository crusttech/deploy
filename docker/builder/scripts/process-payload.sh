#!/usr/bin/env bash

set -eu

PAYLOAD_FILE=${1:-"/tmp/payload.json"}
PAYLOAD=$(cat $PAYLOAD_FILE)

REF=$(echo $PAYLOAD | jq -r '.ref' )
REPO=$(echo $PAYLOAD | jq -r '.repository.name' | cut -d"/" -f 2)
BRANCH=""

case $REF in
  refs/heads/latest)
    BRANCH=$(echo $REF | cut -d"/" -f 3)
    ;;
  *)
    echo "error: unsupported ref $REF"
    exit 0;
    ;;
esac

case $REPO in
  crust)
    ./build-webapp-image.sh --git-repository $REPO --branch=$BRANCH
    ;;
  webapp-*)
    ./build-api-image.sh --git-repository $REPO --branch=$BRANCH
    ;;
  *)
    echo "error: unsupported repository $REPO"
    exit 0;
    ;;
esac
