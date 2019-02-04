#!/usr/bin/env bash

set -eu

PAYLOAD=$(cat -)

REF=$(echo $PAYLOAD | jq -r '.ref' )
REPO=$(echo $PAYLOAD | jq -r '.repository.name' | cut -d"/" -f 2)
BRANCH=""

case $REF in
  refs/heads/beta)
    BRANCH=$(echo $REF | cut -d"/" -f 3)
    ;;
  *)
    echo "error: unsupported ref $REF"
    exit 1;
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
    echo "error: unsupported repostory $REPO"
    exit 1;
    ;;
esac
