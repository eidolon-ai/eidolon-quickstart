.PHONY: serve serve-dev

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

%:
	@:
