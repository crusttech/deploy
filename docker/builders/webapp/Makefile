.PHONY: build push run

TAG=latest
IMAGE=crusttech/webapp-builder

build:
	docker build --no-cache --rm -t $(IMAGE):$(TAG) .

push:
	docker push $(IMAGE):$(TAG)

enter:
	docker run \
  	--volume /var/run/docker.sock:/var/run/docker.sock \
  	--volume `pwd`/entrypoint.sh:/crust/entrypoint.sh \
  	--volume `pwd`/listen.sh:/crust/listen.sh \
  	--volume `pwd`/webhook-handler.sh:/crust/webhook-handler.sh \
  	--privileged -it \
  	--publish 80 \
  	--entrypoint bash \
  	$(IMAGE):$(TAG)

