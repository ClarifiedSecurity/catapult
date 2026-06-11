#!/usr/bin/env bash

${MAKEVAR_SUDO_COMMAND} docker --context default buildx create --name catapult_builder --use --driver-opt network=host
${MAKEVAR_SUDO_COMMAND} docker --context default buildx build ${MAKEVAR_BUILD_ARGS} --tag "${MAKEVAR_IMAGE_FULL}" . --load
${MAKEVAR_SUDO_COMMAND} docker --context default buildx stop catapult_builder
${MAKEVAR_SUDO_COMMAND} docker --context default buildx rm catapult_builder
