#!/usr/bin/env bash

docker inspect nginx-proxy > /dev/null
if [ $? -eq 0 ]
then
    echo "Proxy service already running. Stop/restart must be done manually."
    exit 0
fi

set -eu

# Container running params
DOCKER_RUN="--detach --restart unless-stopped --net=party"

docker run ${DOCKER_RUN} \
    --publish 80:80 --publish 443:443 \
    --label com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy \
    --volume /var/run/docker.sock:/tmp/docker.sock:ro \
    --volume /etc/nginx/certs \
    --volume /etc/nginx/vhost.d \
    --volume /usr/share/nginx/html \
    --name "nginx-proxy" \
    jwilder/nginx-proxy


docker run ${DOCKER_RUN} \
    --volumes-from nginx-proxy \
    --volume /var/run/docker.sock:/var/run/docker.sock:ro \
    --name "nginx-proxy-certmanager" \
    jrcs/letsencrypt-nginx-proxy-companion