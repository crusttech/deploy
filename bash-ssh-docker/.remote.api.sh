#!/usr/bin/env bash

set -eu

# Container running params
DOCKER_RUN="--detach --restart unless-stopped --net=party"

SERVICE=${1}
TAG=${2:-latest}
DEPLOYMENT=${4}
API_CONF_ENV_FILE=~/.api.env.${DEPLOYMENT}
echo ${3}|base64 --decode > ${API_CONF_ENV_FILE}

IMAGE=crusttech/${SERVICE}:${TAG}

function cleanup {
  rm -f ${API_CONF_ENV_FILE}
}

trap cleanup EXIT

docker pull ${IMAGE}

CURRENT=$(docker ps --quiet --all --no-trunc --filter="label=crust.service.type=api.${SERVICE}")

CID=$(docker run ${DOCKER_RUN} \
    --expose 80 \
    --volume /var/opt/crust.${SERVICE}.${TAG}/store:/crust/var/store \
    --env VIRTUAL_HOST=api.${SERVICE}.${TAG}.rustbucket.io \
    --env LETSENCRYPT_HOST=api.${SERVICE}.${TAG}.rustbucket.io \
    --env-file=${API_CONF_ENV_FILE} \
    --hostname api.${SERVICE}.${TAG} \
    --label crust.service.type=api.${SERVICE} \
    --label crust.service.version=${TAG} \
    --name "crust.api.${SERVICE}.${TAG}.${DEPLOYMENT}" \
    ${IMAGE})

# Remove all containers but the one that we just stated
echo ${CURRENT} | xargs --no-run-if-empty -n 1 docker rm -f

echo "> https://api.${SERVICE}.${TAG}.rustbucket.io"