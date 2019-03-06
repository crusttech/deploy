#!/usr/bin/env bash

VERSION=v2.0.1
NAMES="didmos openldap satosa mongodb frontend"

for NAME in $NAMES; do
  echo $NAME
  DAASI_TAG="docker.gitlab.daasi.de/crust/docker-${NAME}/release:${VERSION}"
  CRUST_TAG="crusttech/didmos2-${NAME}:${VERSION}"
  docker pull ${DAASI_TAG}
  docker tag ${DAASI_TAG} ${CRUST_TAG}
  docker push ${CRUST_TAG}
done
