NS ?= akagi201
VERSION ?= latest

IMAGE_NAME ?= janus
CONTAINER_NAME ?= janus
CONTAINER_INSTANCE ?= default

.PHONY: build push shell run start  stop rm release

build: Dockerfile
    docker build -t $(NS)/$(IMAGE_NAME):$(VERSION) -f Dockerfile .

push:
    docker push $(NS)/$(IMAGE_NAME):$(VERSION)

shell:
    docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION) /bin/bash

run:
    docker run --rm --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)

start:
    docker run -d --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)

stop:
    docker stop $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

rm:
    docker rm $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

release: build
    make push -e VERSION=$(VERSION)
    
default: build