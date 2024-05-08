#!/bin/bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

if [[ $1 == "restart" ]]; then

  if ${MAKEVAR_SUDO_COMMAND} docker ps --format "{{ .Names }}" | grep -q "$CONTAINER_NAME"; then

    ${MAKEVAR_SUDO_COMMAND} docker rm -f "${CONTAINER_NAME}" >/dev/null

  fi

fi

if ${MAKEVAR_SUDO_COMMAND} docker ps --format "{{ .Names }}" | grep -q "$CONTAINER_NAME"; then

  echo -n -e "${C_CYAN}"
  echo -e "Connecting to running ${CONTAINER_NAME} container..."
  ${MAKEVAR_SUDO_COMMAND} docker exec -it "${CONTAINER_NAME}" "${CONTAINER_ENTRYPOINT}"

else

  make project-banner --no-print-directory
  echo -n -e "${C_CYAN}"
  make customizations --no-print-directory
  make start-tasks --no-print-directory

  if [[ $(uname) == "Darwin" ]]; then

    echo "Setting correct SSH_AUTH_SOCK for MacOS..."
    export HOST_SSH_AUTH_SOCK=/run/host-services/ssh-auth.sock

  fi

  if [[ $(uname) == "Linux" ]]; then

    echo "Setting correct SSH_AUTH_SOCK for Linux..."
    export HOST_SSH_AUTH_SOCK=${SSH_AUTH_SOCK}

  fi

  ${MAKEVAR_SUDO_COMMAND} docker compose -f "${ROOT_DIR}/docker/docker-compose.yml" -f "${ROOT_DIR}/docker/docker-compose-extra.yml" -f "${ROOT_DIR}/docker/docker-compose-personal.yml" up --detach --force-recreate --remove-orphans
  ${MAKEVAR_SUDO_COMMAND} docker exec -it "${CONTAINER_NAME}" "${CONTAINER_ENTRYPOINT}"

fi

echo -n -e "${C_RST}"