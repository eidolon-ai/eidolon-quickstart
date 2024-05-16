DOCKER_NAMESPACE := eidolon-ai
DOCKER_REPO_NAME := agent-machine
VERSION := $(shell grep -m 1 '^version = ' pyproject.toml | awk -F '"' '{print $$2}')
SDK_VERSION := $(shell grep -m 1 '^eidolon-ai-sdk = ' pyproject.toml | awk -F '[="^]' '{print $$4}')


.PHONY: serve serve-dev check docker docker-bash docker-push _docker-push

# Load environment variables from .env file.
include .env
$(eval export $(shell sed -ne 's/ *#.*$$//; /./ s/=.*$$// p' .env))

check: .env
	@[[ -z "${OPENAI_API_KEY}" ]] && echo "🚨 Error: OPENAI_API_KEY not set" && exit 1 || echo "👍 OPENAI_API_KEY set"

serve-dev: .make/poetry_install .env
	poetry run eidolon-server -m local_dev resources

serve: .make/poetry_install .env
	poetry run eidolon-server resources

.make:
	@mkdir -p .make

.make/poetry_install: .make poetry.lock
	@poetry env use 3.11
	poetry install
	@touch .make/poetry_install

poetry.lock: pyproject.toml
	@poetry lock --no-update
	@touch poetry.lock

.env:
	@cp .template.env .env

docker: poetry.lock
	docker build --build-arg EIDOLON_VERSION=${SDK_VERSION} -t ${DOCKER_NAMESPACE}/${DOCKER_REPO_NAME}:latest -t ${DOCKER_NAMESPACE}/${DOCKER_REPO_NAME}:${VERSION} .

docker-bash: docker
	docker run --rm -it --entrypoint bash ${DOCKER_NAMESPACE}/${DOCKER_REPO_NAME}:latest

docker-push:
	@docker manifest inspect $(DOCKER_NAMESPACE)/${DOCKER_REPO_NAME}:$(VERSION) >/dev/null && echo "Image exists" || $(MAKE) _docker-push

_docker-push: docker
	docker push ${DOCKER_NAMESPACE}/${DOCKER_REPO_NAME}
	docker push ${DOCKER_NAMESPACE}/${DOCKER_REPO_NAME}:${VERSION}
