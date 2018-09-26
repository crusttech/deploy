#!/usr/bin/env bash

#!/usr/bin/env bash

set -eu

cd $(dirname "$0")

SERVICES=${1:-help}
DEPLOYMENT=$(date +%Y-%m-%dT%H%M%S)
DEPLOY_HOST=${DEPLOY_HOST:-rustbucket.io}
DEPLOY_USER=${DEPLOY_USER:-root}

TAG=${2:-"latest"}
HOSTNAME=${3:-"latest"}

CONFIG_API="../api.${HOSTNAME}.env"

if [ -x $CONFIG_API ]
then
    echo "Config file (${CONFIG_API}) not found."
    exit 1
fi

CONFIG_SPA="../spa.${HOSTNAME}.config.js"

if [ -x $CONFIG_SPA ]
then
    echo "Config file (${CONFIG_SPA}) not found."
    exit 1
fi

for SERVICE in $(echo $SERVICES | sed "s/,/ /g")
do
    case $SERVICE in
        proxy)
            ssh ${DEPLOY_USER}@${DEPLOY_HOST} 'bash -s' < \
                ".remote.proxy.sh"

        ;;

        sam|crm|auth)
            ssh ${DEPLOY_USER}@${DEPLOY_HOST} 'bash -s' < \
                ".remote.api.sh" \
                $(base64 ${CONFIG_API}) \
                ${DEPLOYMENT} \
                ${SERVICE} \
                ${TAG} \
                ${HOSTNAME}
        ;;

        spa)
            ssh ${DEPLOY_USER}@${DEPLOY_HOST} 'bash -s' < \
                ".remote.spa.sh" \
                $(base64 ${CONFIG_SPA}) \
                ${DEPLOYMENT} \
                ${TAG} \
                ${HOSTNAME}
        ;;

        *)
            echo "Specify one of the supported services:
     - proxy
     - auth [tag:latest] [host:latest]
     - sam  [tag:latest] [host:latest]
     - crm  [tag:latest] [host:latest]
     - spa  [tag:latest] [host:latest]

Format:
     - [service:help] [tag:latest] [host:latest]

Full combo:
     - spa,auth,sam,crm latest beta
"
    esac
done