#!/bin/bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

echo -n -e ${C_CYAN}

if [[ $(uname) == "Darwin" ]]; then

  echo "Setting correct SSH_AUTH_SOCK for MacOS..."
  export HOST_SSH_AUTH_SOCK=/run/host-services/ssh-auth.sock

fi

if [[ $(uname) == "Linux" ]]; then

  echo "Setting correct SSH_AUTH_SOCK for Linux..."
  export HOST_SSH_AUTH_SOCK=${SSH_AUTH_SOCK}

fi

${MAKEVAR_SUDO_COMMAND} docker compose -f ${ROOT_DIR}/docker/docker-compose.yml -f ${ROOT_DIR}/docker/docker-compose-extra.yml -f ${ROOT_DIR}/docker/docker-compose-personal.yml up --detach --force-recreate --remove-orphans
