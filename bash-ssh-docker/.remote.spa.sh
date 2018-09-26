#!/usr/bin/env bash

set -eu

# Container running params
DOCKER_RUN="--detach --restart unless-stopped --net=party"

DEPLOYMENT=${2}
SERVICE="spa"

SPA_CONFIG_FILE=~/.spa.config.js.${DEPLOYMENT}
echo ${1}|base64 --decode > ${SPA_CONFIG_FILE}


TAG=${3:-latest}
IMAGE=crusttech/${SERVICE}:${TAG}

HOSTNAME=${4:-latest}
FQDN="${HOSTNAME}.rustbucket.io"

docker pull ${IMAGE}


CURRENT=$(docker ps --quiet --all --no-trunc --filter="label=crust.service.fqdn=${FQDN}")

docker run ${DOCKER_RUN} \
    --expose 80 \
    --volume ${SPA_CONFIG_FILE}:/spa/static/config.js:ro \
    --env PORT=80 \
    --env VIRTUAL_HOST=${FQDN} \
    --env LETSENCRYPT_HOST=${FQDN} \
    --hostname ${FQDN} \
    --label "crust.service.fqdn=${FQDN}" \
    --label "crust.service.type=${SERVICE}" \
    --label "crust.service.version=${TAG}" \
    --label "crust.service.hostname=${HOSTNAME}" \
    --name "crust.${SERVICE}.${HOSTNAME}.${DEPLOYMENT}" \
    ${IMAGE}

# Remove all containers but the one that we just stated
echo ${CURRENT} | xargs --no-run-if-empty -n 1 docker rm -f

echo "> https://${FQDN}"