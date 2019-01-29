# Crust webapp builder

For automated, manual or watched build pipeline.

## Automated (cloud.docker.com)
See `crusttech/webapp` for details

## Manual
### Run manual build
```bash
docker run \
	crusttech/webapp-builder --skip-docker-build --skip-docker-push
```

### Run manual build and build docker image
```bash
docker run \
	--volume /var/run/docker.sock:/var/run/docker.sock \
	--privileged \
	crusttech/webapp-builder --skip-docker-push
```

Builds `crusttech/webapp:latest` from `latest` branches and pushes it to docker hub.

### Run manual build and push image
```bash
docker run \
	--volume docker-config.json:/root/.docker/config.json:ro \
	--volume /var/run/docker.sock:/var/run/docker.sock \
	--privileged \
	crusttech/webapp-builder 
```

Builds `crusttech/webapp:latest` from `latest` branches and pushes it to docker hub.

### Watched 
```bash
docker run \
	--volume docker-config.json:/root/.docker/config.json:ro \
	--volume /var/run/docker.sock:/var/run/docker.sock \
	--privileged \
	--env VIRTUAL_HOST=some-host \
	--env LETSENCRYPT_HOST=some-host \
	--env LISTEN_PORT=80 \
	--env TRIGGER_TOKEN=trigger_token_string \
	--publish 80 \
	crusttech/webapp-builder
```


# Dev notes
## Build image locally and push it back

```bash
make build
make push
```

## Enter into container, dev-mode
With entrypoint.sh mapped, interactive and alocated pseudo TTY
```bash
make enter
```
