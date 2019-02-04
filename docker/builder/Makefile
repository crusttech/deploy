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
  	--volume `pwd`/scripts:/scripts \
  	--privileged -it \
  	--publish 80 \
  	--entrypoint bash \
  	$(IMAGE):$(TAG)

