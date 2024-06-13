DOCKER_NAMESPACE := eidolon-ai
DOCKER_REPO_NAME := agent-machine
VERSION := $(shell grep -m 1 '^version = ' pyproject.toml | awk -F '"' '{print $$2}')
SDK_VERSION := $(shell grep -m 1 '^eidolon-ai-sdk = ' pyproject.toml | awk -F '[="^]' '{print $$4}')
REQUIRED_ENVS := OPENAI_API_KEY

.PHONY: serve serve-dev check docker docker-bash docker-push _docker-push .env

serve-dev: .make/poetry_install .env
	@echo "Starting Server..."
	@poetry run eidolon-server -m local_dev resources --dotenv .env

serve: .make/poetry_install .env
	@echo "Starting Server..."
	@poetry run eidolon-server resources --dotenv .env

.env: Makefile
	@touch .env
	@source .env; \
	for var in $(REQUIRED_ENVS); do \
		if [ -z "$${!var}" ]; then \
			read -p "💭 $$var (required): " input; \
			if [ -n "$$input" ]; then \
				echo "$$var=$$input" >> .env; \
			else \
				echo "🚨 Error: $$var is required"; \
				exit 1; \
			fi; \
		fi; \
	done;

.make:
	@mkdir -p .make

.make/poetry_install: .make poetry.lock
	@poetry env use 3.11
	poetry install
	@touch .make/poetry_install

poetry.lock: pyproject.toml
	@poetry lock --no-update
	@touch poetry.lock

docker: poetry.lock
	docker build --build-arg EIDOLON_VERSION=${SDK_VERSION} -t ${DOCKER_NAMESPACE}/${DOCKER_REPO_NAME}:latest -t ${DOCKER_NAMESPACE}/${DOCKER_REPO_NAME}:${VERSION} .

docker-bash: docker
	docker run --rm -it --entrypoint bash ${DOCKER_NAMESPACE}/${DOCKER_REPO_NAME}:latest

docker-push:
	@docker manifest inspect $(DOCKER_NAMESPACE)/${DOCKER_REPO_NAME}:$(VERSION) >/dev/null && echo "Image exists" || $(MAKE) _docker-push

_docker-push: docker
	docker push ${DOCKER_NAMESPACE}/${DOCKER_REPO_NAME}
	docker push ${DOCKER_NAMESPACE}/${DOCKER_REPO_NAME}:${VERSION}
