#!/bin/bash

set -e

echo -n -e ${C_CYAN}

# Running make docker-login commands
if [[ $1 == "docker-login" ]]; then

  ${MAKEVAR_SUDO_COMMAND} docker login ${MAKEVAR_CONTAINER_REGISTRY}

  if [[ $(uname) == "Linux" ]]; then

    ${MAKEVAR_SUDO_COMMAND} cp -ar ~/.docker /root/

  fi

fi