DOCKER_NAMESPACE := eidolon-ai
DOCKER_REPO_NAME := agent-machine
VERSION := $(shell grep -m 1 '^version = ' pyproject.toml | awk -F '"' '{print $$2}')
SDK_VERSION := $(shell grep -m 1 '^eidolon-ai-sdk = ' pyproject.toml | awk -F '[="^]' '{print $$4}')
REQUIRED_ENVS := OPENAI_API_KEY

.PHONY: serve serve-dev check docker docker-bash docker-push _docker-push .env sync update

ARGS ?=

serve-dev: .make/poetry_install .env
	@echo "Starting Server..."
	@poetry run eidolon-server -m local_dev resources --dotenv .env $(ARGS)

serve: .make/poetry_install .env
	@echo "Starting Server..."
	@poetry run eidolon-server resources --dotenv .env $(ARGS)

.env: Makefile
	@touch .env
	@for var in $(REQUIRED_ENVS); do \
		if [ -z "$$(eval echo \$$$$var)" ] && ! grep -q "^$$var=" .env; then \
			read -p "💭 $$var (required): " input; \
			if [ -n "$$input" ]; then \
				echo "$$var=$$input" >> .env; \
			else \
				echo "🚨 Error: $$var is required"; \
				exit 1; \
			fi; \
		else \
			if ! grep -q "^$$var=" .env; then \
				echo "$$var=$$(eval echo \$$$$var)" >> .env; \
			fi; \
		fi; \
	done;

.make:
	@mkdir -p .make

.make/poetry_install: .make poetry.lock
	poetry install
	@touch .make/poetry_install

poetry.lock: pyproject.toml
	@poetry lock --no-update
	@touch poetry.lock

check-docker-daemon:
	@docker info >/dev/null 2>&1 || (echo "🚨 Error: Docker daemon is not running\n🛟 For help installing or running docker, visit https://docs.docker.com/get-docker/" >&2 && exit 1)

docker: poetry.lock check-docker-daemon
	docker build --build-arg EIDOLON_VERSION=${SDK_VERSION} -t ${DOCKER_NAMESPACE}/${DOCKER_REPO_NAME}:latest -t ${DOCKER_NAMESPACE}/${DOCKER_REPO_NAME}:${VERSION} .

docker-serve: docker .env
	docker run -p 8080:8080 --env-file .env --mount src=$$(pwd)/resources,target=/bound_resources/,type=bind ${DOCKER_NAMESPACE}/${DOCKER_REPO_NAME}:latest /bound_resources -m local_dev

docker-bash: docker
	docker run --rm -it --entrypoint bash ${DOCKER_NAMESPACE}/${DOCKER_REPO_NAME}:latest

docker-push:
	@docker manifest inspect $(DOCKER_NAMESPACE)/${DOCKER_REPO_NAME}:$(VERSION) >/dev/null && echo "Image exists" || $(MAKE) _docker-push

_docker-push: docker
	docker push ${DOCKER_NAMESPACE}/${DOCKER_REPO_NAME}
	docker push ${DOCKER_NAMESPACE}/${DOCKER_REPO_NAME}:${VERSION}

update:
	poetry add eidolon-ai-sdk@latest
	poetry lock --no-update

sync:
	@if git remote | grep -q upstream; then \
		echo "upstream already exists"; \
	else \
		git remote add upstream https://github.com/eidolon-ai/agent-machine.git; \
		echo "upstream added"; \
	fi
	git fetch upstream
	git merge upstream/main --no-edit
