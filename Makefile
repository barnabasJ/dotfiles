IMAGE_NAME := chezmoi-test
IMAGE_TAG := latest

# Pass GITHUB_TOKEN as a build secret to avoid GitHub API rate limits
# during mise package installs. Falls back to `gh auth token` if env unset.
.PHONY: build test test-quick shell clean

build:
	@token="$${GITHUB_TOKEN}"; \
	if [ -z "$$token" ] && command -v gh >/dev/null 2>&1; then \
	  token="$$(gh auth token 2>/dev/null || true)"; \
	fi; \
	if [ -n "$$token" ]; then \
	  GITHUB_TOKEN="$$token" docker build --secret id=gh_token,env=GITHUB_TOKEN \
	    -t $(IMAGE_NAME):$(IMAGE_TAG) -f test/Containerfile .; \
	else \
	  echo "Warning: no GITHUB_TOKEN available — build may hit GitHub API rate limits"; \
	  docker build -t $(IMAGE_NAME):$(IMAGE_TAG) -f test/Containerfile .; \
	fi

test: build
	docker run --rm $(IMAGE_NAME):$(IMAGE_TAG)

test-quick:
	docker run --rm $(IMAGE_NAME):$(IMAGE_TAG)

shell: build
	docker run --rm -it $(IMAGE_NAME):$(IMAGE_TAG) bash

clean:
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null || true
