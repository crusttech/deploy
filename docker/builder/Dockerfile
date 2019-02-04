FROM node:10-alpine AS builder

RUN apk add bash git coreutils less docker openssl jq
RUN npm i -g yarn

RUN mkdir -p /scripts
WORKDIR /scripts

ADD ./scripts/*.sh /scripts/
RUN chmod a+x /scripts/*.sh

EXPOSE 80

ENTRYPOINT ["/scripts/build.sh"]
