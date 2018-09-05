#!/usr/bin/env bash

set -eu

# Container running params
DOCKER_RUN="--detach --restart unless-stopped --net=party"

TAG=${1:-latest}
DEPLOYMENT=${2}

IMAGE=crusttech/spa:${TAG}

docker pull ${IMAGE}

# @todo if TAG=production then VIRTUAL_HOST=www.rustbucket.io

CID=$(docker run ${DOCKER_RUN} \
    --expose 80 \
    --env PORT=80 \
    --env VIRTUAL_HOST=${TAG}.rustbucket.io \
    --env LETSENCRYPT_HOST=${TAG}.rustbucket.io \
    --label crust.service.type=spa.spa \
    --label crust.service.version=spa.spa \
    --name "crust.spa.${TAG}.${DEPLOYMENT}" \
    ${IMAGE})

# Remove all containers but the one that we just stated
docker ps --quiet --all --no-trunc --filter="ancestor=${IMAGE}" |
    grep --invert-match $CID |
    xargs --no-run-if-empty -n 1 docker rm -f

echo "> https://${TAG}.rustbucket.io"