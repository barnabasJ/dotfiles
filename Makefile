IMAGE_NAME := chezmoi-test
IMAGE_TAG := latest

.PHONY: build test test-quick shell clean

build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) -f test/Containerfile .

test: build
	docker run --rm $(IMAGE_NAME):$(IMAGE_TAG)

test-quick:
	docker run --rm $(IMAGE_NAME):$(IMAGE_TAG)

shell: build
	docker run --rm -it $(IMAGE_NAME):$(IMAGE_TAG) bash

clean:
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null || true
