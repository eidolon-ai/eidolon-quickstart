DOCKER_NAMESPACE := eidolon-ai
DOCKER_REPO_NAME := agent-machine
VERSION := $(shell grep -m 1 '^version = ' pyproject.toml | awk -F '"' '{print $$2}')
SDK_VERSION := $(shell grep -m 1 '^eidolon-ai-sdk = ' pyproject.toml | awk -F '[="^]' '{print $$4}')
REQUIRED_ENVS := OPENAI_API_KEY

.PHONY: serve serve-dev check docker-serve .env sync update

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
	@ANON_ID=$$(hostname | { { md5sum 2>/dev/null || md5 2>/dev/null || shasum -a 256 2>/dev/null || sha256sum 2>/dev/null; } | awk '{print $$1}' || echo "unknown"; }) && \
	if ! grep -q "^POSTHOG_ID=" .env; then \
		echo "POSTHOG_ID=$$ANON_ID" >> .env; \
	fi;

.make:
	@mkdir -p .make

.make/poetry_install: .make poetry.lock
	poetry install
	@touch .make/poetry_install

poetry.lock: pyproject.toml
	@poetry lock --no-update
	@touch poetry.lock

Dockerfile: pyproject.toml
	@sed -i '' 's/^ARG EIDOLON_VERSION=.*/ARG EIDOLON_VERSION=${SDK_VERSION}/' Dockerfile
	@echo "Updated Dockerfile with EIDOLON_VERSION=${SDK_VERSION}"


check-docker-daemon:
	@docker info >/dev/null 2>&1 || (echo "🚨 Error: Docker daemon is not running\n🛟 For help installing or running docker, visit https://docs.docker.com/get-docker/" >&2 && exit 1)

docker-serve: .env check-docker-daemon poetry.lock
	@docker-compose up

update:
	poetry add eidolon-ai-sdk@latest
	poetry lock --no-update
	$(MAKE) Dockerfile

sync:
	@if git remote | grep -q upstream; then \
		echo "upstream already exists"; \
	else \
		git remote add upstream https://github.com/eidolon-ai/agent-machine.git; \
		echo "upstream added"; \
	fi
	git fetch upstream
	git merge upstream/main --no-edit
