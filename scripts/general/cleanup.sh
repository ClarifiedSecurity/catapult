#!/bin/bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

echo -n -e ${C_CYAN}
echo -e "Cleaning up Catapult..."

# Deleting Catapult container if it exists
if ${MAKEVAR_SUDO_COMMAND} docker ps -a | grep -q ${CONTAINER_NAME}; then

    echo -e "Deleting ${CONTAINER_NAME} container..."
    ${MAKEVAR_SUDO_COMMAND} docker rm -f ${CONTAINER_NAME}

fi

# Deleting Catapult image if it exists
if ${MAKEVAR_SUDO_COMMAND} docker images | grep -q ${IMAGE_FULL}; then

    echo -e "Deleting ${IMAGE_FULL} image..."
    ${MAKEVAR_SUDO_COMMAND} docker rmi -f ${IMAGE_FULL}

fi
