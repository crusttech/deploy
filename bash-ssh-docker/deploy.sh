#!/usr/bin/env bash

#!/usr/bin/env bash

set -x
set -eu

cd $(dirname "$0")

source .env

SERVICE=${1:-help}
DEPLOYMENT=$(date +%Y-%m-%dT%H%M%S)
DEPLOY_HOST=${DEPLOY_HOST:-rustbucket.io}
DEPLOY_USER=${DEPLOY_USER:-root}


case $SERVICE in
    proxy)
        ssh ${DEPLOY_USER}@${DEPLOY_HOST} 'bash -s' < \
            ".remote.proxy.sh"

    ;;

    sam|crm)
        TAG=${2:-"latest"}

        ssh ${DEPLOY_USER}@${DEPLOY_HOST} 'bash -s' < \
            ".remote.api.sh" \
            ${SERVICE} \
            ${TAG} \
            $(base64 ../api.conf.env) \
            ${DEPLOYMENT}
    ;;

    spa)
        TAG=${2:-"latest"}

        ssh ${DEPLOY_USER}@${DEPLOY_HOST} 'bash -s' < \
            ".remote.spa.sh" \
            ${TAG} \
            ${DEPLOYMENT}
    ;;

    *)
        echo "Specify one of the supported services:

 - proxy
 - sam [tag:latest]
 - crm [tag:latest]
 - spa [tag:latest]
        "
esac