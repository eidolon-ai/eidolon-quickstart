ARG EIDOLON_VERSION
FROM python:3.11-slim as builder
RUN pip install poetry
COPY pyproject.toml pyproject.toml
COPY poetry.lock poetry.lock
COPY components/ components/
COPY README.md README.md
RUN mkdir dist
RUN touch dist/requirements.txt
RUN poetry export --without dev --without-hashes --format=requirements.txt | sed '/@ file/d' > dist/requirements.txt
RUN poetry build

FROM docker.io/eidolonai/sdk_base:$EIDOLON_VERSION as agent-machine

# First copy builder requirements so dependency cache layer is cached
COPY --from=builder dist/requirements.txt /tmp/agent-machine/requirements.txt
RUN pip install -r /tmp/agent-machine/requirements.txt

# Then install poetry project wheel since it will change more frequently
COPY --from=builder dist/*.whl /tmp/agent-machine/
RUN pip install /tmp/agent-machine/*.whl

# Finally copy resources over since they will mutate most frequently
COPY resources/ /app/resources/

FROM agent-machine
WORKDIR /app
RUN addgroup --system --gid 1001 eidolon
RUN adduser --system --uid 1001 eidolon

USER eidolon
EXPOSE 8080
ENV PYTHONUNBUFFERED 1
ENTRYPOINT ["eidolon-server"]
CMD ["resources"]