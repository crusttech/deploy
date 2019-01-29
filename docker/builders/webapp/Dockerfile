FROM node:10-alpine AS builder

RUN apk add bash git coreutils less docker openssl
RUN npm i -g yarn

RUN mkdir -p /crust
WORKDIR /crust

ADD ./*.sh /crust/
RUN chmod a+x /crust/*.sh

# Files we need for standalone building where entrypoint.sh builds and
# pushes final image (see src/Dockerfile)
ADD ./src/Dockerfile /crust/
ADD ./src/nginx.conf /crust/

ENTRYPOINT ["/crust/entrypoint.sh"]
