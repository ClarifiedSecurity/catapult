#!/usr/bin/env bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

echo -n -e "${C_CYAN}"
echo -e "Cleaning up Catapult..."

# Deleting Catapult container if it exists
if ${MAKEVAR_SUDO_COMMAND} docker --context default ps -a | grep -q "${CONTAINER_NAME}"; then

    echo -e "Deleting ${CONTAINER_NAME} container..."
    ${MAKEVAR_SUDO_COMMAND} docker --context default rm -f "${CONTAINER_NAME}"

fi

# Deleting any existing Catapult images
if [[ $(${MAKEVAR_SUDO_COMMAND} docker --context default images "${MAKEVAR_CONTAINER_REGISTRY}/${MAKEVAR_IMAGE_NAME}" | wc -l) -gt 1 ]]; then

    echo -e "Deleting ${MAKEVAR_CONTAINER_REGISTRY}/${MAKEVAR_IMAGE_NAME} images..."
    ${MAKEVAR_SUDO_COMMAND} docker --context default images "${MAKEVAR_CONTAINER_REGISTRY}/${MAKEVAR_IMAGE_NAME}" -q | xargs docker rmi -f

fi

echo -e -n "${C_RST}"