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
DOCKER_IMAGE_TAG="${BRANCH}"
DOCKER_IMAGE=${DOCKER_IMAGE:-"crusttech/webapp:${DOCKER_IMAGE_TAG}"}
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

yarnInstall () {
  [[ ${SKIP_YARN_INSTALL} == "1" ]] && return 0
  REPO=$1

  (
    cd $REPO
    yarn $YARN_CONFIG install
    cd ..
  ) 2>&1 | pfix "yarn install $REPO"
}

yarnBuild () {
  [[ ${SKIP_YARN_BUILD} == "1" ]] && return 0
  REPO=$1

  (
    cd $REPO
    yarn $YARN_CONFIG build
    cd ..
  ) 2>&1 | pfix "yarn build $REPO"
}

dockerBuild () {
  [[ ${SKIP_DOCKER_BUILD} == "1" ]] && return 0

  (
    cd final
    docker build --no-cache --rm ${QUIET_DOCKER} --tag ${DOCKER_IMAGE} .
  ) 2>&1 | pfix "docker build"
}

dockerPush () {
  [[ ${SKIP_DOCKER_PUSH} == "1" ]] && return 0

  (
    docker push ${DOCKER_IMAGE}
  ) 2>&1 | pfix "docker push"
}

START_TIME=$SECONDS

printf "webapp builder (branch: $BRANCH)\tstart at %s\n" `date +%Y-%m-%dT%H:%M:%SZ`

# Make sure we build each brench separated from the rest
BUILD_DIR="/build/webapp/$BRANCH"
mkdir -p $BUILD_DIR && cd $BUILD_DIR

gitUpdate webapp-unify
gitUpdate webapp-crm
gitUpdate webapp-messaging
gitUpdate webapp-admin

yarnInstall webapp-unify
yarnInstall webapp-crm
yarnInstall webapp-messaging
yarnInstall webapp-admin

yarnBuild webapp-unify
yarnBuild webapp-crm
yarnBuild webapp-messaging
yarnBuild webapp-admin

rm -rf final
mkdir -p final

mv webapp-unify/dist      ./final
mv webapp-crm/dist        ./final/dist/crm
mv webapp-messaging/dist  ./final/dist/messaging
mv webapp-admin/dist      ./final/dist/admin

cp webapp-unify/docker/Dockerfile ./final/
cp webapp-unify/docker/nginx.conf ./final/

dockerBuild
dockerPush

printf "webapp builder\tcompleted in %ss\n" $(($SECONDS - $START_TIME))
