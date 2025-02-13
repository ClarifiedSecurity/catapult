#!/usr/bin/env bash

DOCKER_HOST=unix:///var/run/docker.sock ${MAKEVAR_SUDO_COMMAND} docker buildx create --use --driver-opt network=host
# shellcheck disable=SC2086
DOCKER_HOST=unix:///var/run/docker.sock ${MAKEVAR_SUDO_COMMAND} docker buildx build ${BUILD_ARGS} --network host --progress plain --tag "${IMAGE_FULL}" . --load
