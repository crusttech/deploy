#!/usr/bin/env bash

set -eu

# Container running params
DOCKER_RUN="--detach --restart unless-stopped --net=party"


DEPLOYMENT=${2}
SERVICE=${3}

API_CONF_ENV_FILE=~/.api.env.${DEPLOYMENT}
echo ${1}|base64 --decode > ${API_CONF_ENV_FILE}

TAG=${4:-latest}
IMAGE=crusttech/${SERVICE}:${TAG}

HOSTNAME=${5:-latest}
FQDN="${SERVICE}.api.${HOSTNAME}.rustbucket.io"

function cleanup {
  rm -f ${API_CONF_ENV_FILE}
}

trap cleanup EXIT

docker pull ${IMAGE}

CURRENT=$(docker ps --quiet --all --no-trunc --filter="label=crust.service.fqdn=${FQDN}")

docker run ${DOCKER_RUN} \
    --expose 80 \
    --volume /var/opt/crust.${SERVICE}.${HOSTNAME}/store:/crust/var/store \
    --env VIRTUAL_HOST=${FQDN} \
    --env LETSENCRYPT_HOST=${FQDN} \
    --env-file=${API_CONF_ENV_FILE} \
    --hostname ${FQDN} \
    --label "crust.service.fqdn=${FQDN}" \
    --label "crust.service.type=api.${SERVICE}" \
    --label "crust.service.version=${TAG}" \
    --label "crust.service.hostname=${HOSTNAME}" \
    --name "crust.api.${SERVICE}.${HOSTNAME}.${DEPLOYMENT}" \
    ${IMAGE}

# Remove all containers but the one that we just stated
echo ${CURRENT} | xargs --no-run-if-empty -n 1 docker rm -f

echo "> https://${FQDN}"
