#!/usr/bin/env bash

set -eu

GIT_REMOTE_BASE=${GIT_REMOTE_BASE:-"https://github.com/crusttech"}
QUIET_GIT=${QUIET_GIT:-""}
QUIET_DOCKER=${QUIET_DOCKER:-""}
BRANCH=${BRANCH:-"latest"}
SKIP_GIT_UPDATE=0
SKIP_DOCKER_BUILD=0
SKIP_DOCKER_PUSH=0
DOCKER_IMAGE_TAG="${BRANCH}"
YARN_CONFIG=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --quiet-git)
            QUIET_GIT="--quiet"
            shift;
        ;;

        --quiet-docker)
            QUIET_DOCKER="--quiet"
            shift;
        ;;

        --debug)
            set -x
            shift;
        ;;

        --branch)
            BRANCH=$2
            shift;
            shift;
        ;;

        --skip-git-update)
            SKIP_GIT_UPDATE=1
            shift;
        ;;

        --skip-docker-build)
            SKIP_DOCKER_BUILD=1
            shift;
        ;;

        --skip-docker-push)
            SKIP_DOCKER_PUSH=1
            shift;
        ;;

        --docker-image)
            DOCKER_IMAGE=$2
            shift;
            shift;
        ;;

        *)
            # Ignore unknown params
            shift
        ;;
    esac;
done

pfix () {
    PREFIX=${1:-""}
    while read line; do
      echo -e "$PREFIX\t$line"
    done
}

gitUpdate () {
    [[ ${SKIP_GIT_UPDATE} == "1" ]] && return 0
    REPO=$1

    (
      if [ -d ${REPO} ]; then
          git -C ${REPO} reset --hard
          git -C ${REPO} pull --force -n
      else
          git clone ${QUIET_GIT} -b ${BRANCH} "${GIT_REMOTE_BASE}/${REPO}.git" ${REPO}
      fi;
    ) 2>&1 | pfix "git clone/fetch $REPO"
}

dockerBuild () {
  [[ ${SKIP_DOCKER_BUILD} == "1" ]] && return 0

  (
    cd crust
    docker build --no-cache --rm ${QUIET_DOCKER} --file Dockerfile.${1} --tag crusttech/api-${1}:${DOCKER_IMAGE_TAG} .
    cd ..
  ) 2>&1 | pfix "docker build ${1}"
}

dockerPush () {
  [[ ${SKIP_DOCKER_PUSH} == "1" ]] && return 0

  (
    docker push crusttech/api-${1}:${DOCKER_IMAGE_TAG}
  ) 2>&1 | pfix "docker push ${1}"
}

START_TIME=$SECONDS

printf "api builder (branch: $BRANCH)\tstart at %s\n" `date +%Y-%m-%dT%H:%M:%SZ`

# Make sure we build each brench separated from the rest
BUILD_DIR="/build/api/$BRANCH"
mkdir -p $BUILD_DIR && cd $BUILD_DIR

gitUpdate crust

dockerBuild system
dockerBuild messaging
dockerBuild crm

dockerPush system
dockerPush messaging
dockerPush crm

printf "webapp builder\tcompleted in %ss\n" $(($SECONDS - $START_TIME))
