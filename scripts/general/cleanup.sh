#!/bin/bash

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

# Deleting Catapult network if it exists
if ${MAKEVAR_SUDO_COMMAND} docker network ls | grep -q ${CONTAINER_NETWORK}; then

    echo -e "Deleting ${CONTAINER_NETWORK} network..."
    ${MAKEVAR_SUDO_COMMAND} docker network rm ${CONTAINER_NETWORK}

fi