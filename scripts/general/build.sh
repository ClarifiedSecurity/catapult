#!/usr/bin/env bash

${MAKEVAR_SUDO_COMMAND} docker --context default buildx create --use --driver-opt network=host
${MAKEVAR_SUDO_COMMAND} docker --context default buildx build ${BUILD_ARGS} --network host --progress plain --tag "${IMAGE_FULL}" . --load
