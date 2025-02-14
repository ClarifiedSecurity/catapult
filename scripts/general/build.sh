#!/usr/bin/env bash

# Setting the DOCKER_HOST for Linux
# This is to make sure rootful Docker is used
if [[ $(uname) == "Linux" ]]; then

    # Checking if MAKEVAR_DOCKER_SOCKET_PATH is not empty
    # This is for setting non-default Docker socket path
    if [[ -z "${MAKEVAR_DOCKER_SOCKET_PATH}" ]]; then

        export DOCKER_HOST=unix:///var/run/docker.sock

    else

        export DOCKER_HOST=${MAKEVAR_DOCKER_SOCKET_PATH}

    fi

fi

${MAKEVAR_SUDO_COMMAND} docker buildx create --use --driver-opt network=host
${MAKEVAR_SUDO_COMMAND} docker buildx build ${BUILD_ARGS} --network host --progress plain --tag "${IMAGE_FULL}" . --load

unset DOCKER_HOST