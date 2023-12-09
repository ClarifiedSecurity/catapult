#!/bin/bash

set -e

echo -n -e ${C_CYAN}

if [[ $(uname) == "Darwin" ]]; then

  echo "Setting correct SSH_AUTH_SOCK for MacOS..."
  export HOST_SSH_AUTH_SOCK=/run/host-services/ssh-auth.sock

fi

if [[ $(uname) == "Linux" ]]; then

  echo "Setting correct SSH_AUTH_SOCK for Linux..."
  export HOST_SSH_AUTH_SOCK=${SSH_AUTH_SOCK}

fi

${MAKEVAR_SUDO_COMMAND} $HOME/.local/bin/podman-compose -f ${ROOT_DIR}/compose/docker-compose.yml -f ${ROOT_DIR}/compose/docker-compose-extra.yml -f ${ROOT_DIR}/compose/docker-compose-personal.yml up -d --remove-orphans --force-recreate > /dev/null 2>&1
