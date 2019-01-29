#!/usr/bin/env bash

set -eu

GIT_REMOTE_BASE=${GIT_REMOTE_BASE:-"https://github.com/crusttech"}
QUIET_GIT=${QUIET_GIT:-""}
QUIET_DOCKER=${QUIET_DOCKER:-""}
BRANCH=${BRANCH:-"latest"}
SKIP_GIT_UPDATE=0
SKIP_YARN_INSTALL=0
SKIP_YARN_BUILD=0
#SKIP_TESTS=0
SKIP_DOCKER_BUILD=0
SKIP_DOCKER_PUSH=0
IMAGE_TAG="${BRANCH}"
IMAGE=${IMAGE:-"crusttech/webapp:${IMAGE_TAG}"}
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

        --skip-yarn-install)
            SKIP_YARN_INSTALL=1
            shift;
        ;;

        --skip-yarn-build)
            SKIP_YARN_BUILD=1
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

        --image)
            IMAGE=$2
            shift;
            shift;
        ;;

        *)
            # Ignore unknown params
            shift
        ;;
    esac;
done


DEPLOY_SCRIPT="/opt/deploy/deploy.sh"

pfix () {
    PREFIX=${1:-""}
    while read line; do
      printf "$PREFIX\t$line\n"
    done
}


build () {
    IMAGE="crusttech/${1}"
    PARAMS=${2-""}
    echo "Building docker image ${IMAGE}"
    docker build ${QUIET_DOCKER} --no-cache --rm ${PARAMS} -t ${IMAGE} .
}


push () {
    IMAGE="crusttech/${1}"
    echo "Pushing docker image ${IMAGE} to dockerhub"
    docker push ${IMAGE}
}

gitUpdate () {
    [[ ${SKIP_GIT_UPDATE} == "1" ]] && return 0
    APP=$1

    (
    if [ -d ${APP} ]; then
        git -C ${APP} fetch ${QUIET_GIT} --all --prune
    else
        git clone ${QUIET_GIT} --depth=1 "${GIT_REMOTE_BASE}/${APP}.git"
    fi;
    ) 2>&1 | pfix "git clone/fetch $APP"
}

yarnInstall () {
  [[ ${SKIP_YARN_INSTALL} == "1" ]] && return 0
  APP=$1

  (
  cd $APP
  yarn $YARN_CONFIG install
  cd ..
  ) 2>&1 | pfix "yarn install $APP"
}

yarnBuild () {
  [[ ${SKIP_YARN_BUILD} == "1" ]] && return 0
  APP=$1

  (
  cd $APP
  yarn $YARN_CONFIG build
  cd ..
  ) 2>&1 | pfix "yarn build $APP"
}

dockerBuild () {
  [[ ${SKIP_DOCKER_BUILD} == "1" ]] && return 0

  (
  docker build ${QUIET_DOCKER} --tag ${IMAGE} .
  ) 2>&1 | pfix "docker build"
}

dockerPush () {
  [[ ${SKIP_DOCKER_PUSH} == "1" ]] && return 0

  (
  docker push ${IMAGE}
  ) 2>&1 | pfix "docker push"
}

START_TIME=$SECONDS

printf "webapp builder\tstart at %s\n" `date +%Y-%m-%dT%H:%M:%SZ`

gitUpdate webapp-chrome # @todo rename to webapp-unify
gitUpdate webapp-crm
gitUpdate webapp-messaging
gitUpdate webapp-admin

yarnInstall webapp-chrome # @todo rename to webapp-unify
yarnInstall webapp-crm
yarnInstall webapp-messaging
yarnInstall webapp-admin

yarnBuild webapp-chrome # @todo rename to webapp-unify
yarnBuild webapp-crm
yarnBuild webapp-messaging
yarnBuild webapp-admin

rm -rf ./dist
mv webapp-chrome/dist     ./
mv webapp-crm/dist        ./dist/crm
mv webapp-messaging/dist  ./dist/messaging
mv webapp-admin/dist  ./dist/admin

dockerBuild
dockerPush

printf "webapp builder\tcompleted in %ss\n" $(($SECONDS - $START_TIME))
