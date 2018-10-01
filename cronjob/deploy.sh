#!/usr/bin/env bash


APP=""
TAG="latest"
FQDN=""
FORCE=0

while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--app)
            APP=$2
            shift;shift;
        ;;

        -t|--tag)
            TAG=$2
            shift;shift;
        ;;

        --fqdn)
            FQDN=$2
            shift;shift
        ;;

        --force)
            FORCE=1
            shift
        ;;

        *)
            # Ignore unknown params
            shift
        ;;
    esac;
done

if [[ "${FQDN}" == "" ]]; then
    echo "FQDN not specified"
fi;

CONFIG="/opt/deploy/${FQDN}"

if [[ "${APP}" == "" ]]; then
    echo "Image not specified"
fi;

IMAGE="crusttech/${APP}:${TAG}"

if [[ "${FORCE}" -eq "1" ]]; then
    # Deploy, even if image is not updated (--force)
    docker pull "${IMAGE}"
else
    # Deplou only when image is not updated
    (docker pull "${IMAGE}" | grep "Image is up to date") && exit 0
fi;

## Is there a container already running?
CURRENT=$(docker ps --quiet --all --no-trunc --filter="label=crust.fqdn=${FQDN}")


# Container running params
DOCKER_RUN_PARAMS=""

APP_DOCKER_PARAMS=""
case "${APP}" in
    webapp)
        APP_DOCKER_PARAMS="${APP_DOCKER_PARAMS} --volume ${CONFIG}.messaging.config.js:/crust/webapp/messaging/config.js:ro"
        APP_DOCKER_PARAMS="${APP_DOCKER_PARAMS} --env PORT=80"
    ;;
    api-*)
        APP_DOCKER_PARAMS="${APP_DOCKER_PARAMS} --volume /var/opt/${FQDN}/store:/crust/var/store"
        APP_DOCKER_PARAMS="${APP_DOCKER_PARAMS} --env-file=${CONFIG}.env"
    ;;
    *)
        echo "Unknown app"
        exit 1

esac

CONTAINER_NAME="${FQDN}-$(date +%Y-%m-%dT%H%M%S)"

docker run --detach --restart unless-stopped --net=party \
    ${APP_DOCKER_PARAMS} \
    --expose 80 \
    --env VIRTUAL_HOST=${FQDN} \
    --env LETSENCRYPT_HOST=${FQDN} \
    --hostname ${FQDN} \
    --label "crust.fqdn=${FQDN}" \
    --label "crust.app=${APP}" \
    --name "${CONTAINER_NAME}" \
    ${IMAGE}



# Remove all containers but the one that we just stated
echo ${CURRENT} | xargs --no-run-if-empty -n 1 docker rm -f