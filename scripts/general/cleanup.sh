#!/bin/bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

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

echo -n -e "${C_CYAN}"
echo -e "Cleaning up Catapult..."

# Deleting Catapult container if it exists
if ${MAKEVAR_SUDO_COMMAND} docker ps -a | grep -q "${CONTAINER_NAME}"; then

    echo -e "Deleting ${CONTAINER_NAME} container..."
    ${MAKEVAR_SUDO_COMMAND} docker rm -f "${CONTAINER_NAME}"

fi

# Deleting any existing Catapult images
if [[ $(${MAKEVAR_SUDO_COMMAND} docker images "${MAKEVAR_CONTAINER_REGISTRY}/${MAKEVAR_IMAGE_NAME}" | wc -l) -gt 1 ]]; then

    echo -e "Deleting ${MAKEVAR_CONTAINER_REGISTRY}/${MAKEVAR_IMAGE_NAME} images..."
    ${MAKEVAR_SUDO_COMMAND} docker images "${MAKEVAR_CONTAINER_REGISTRY}/${MAKEVAR_IMAGE_NAME}" -q | xargs docker rmi -f

fi

unset DOCKER_HOST

echo -e -n "${C_RST}"