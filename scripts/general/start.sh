#!/bin/bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

make project-banner --no-print-directory

if [[ $1 == "stop" ]]; then

    echo -n -e "${C_YELLOW}"
    echo -e Removing existing "${CONTAINER_NAME} container..."
    ${MAKEVAR_SUDO_COMMAND} docker rm -f "${CONTAINER_NAME}" >/dev/null
    echo -n -e "${C_RST}"
    exit 0
fi

if [[ $1 == "restart" ]]; then

  if ${MAKEVAR_SUDO_COMMAND} docker ps --format "{{ .Names }}" | grep -q "$CONTAINER_NAME"; then

    echo -n -e "${C_YELLOW}"
    echo -e Removing existing "${CONTAINER_NAME} container..."
    ${MAKEVAR_SUDO_COMMAND} docker rm -f "${CONTAINER_NAME}" >/dev/null
    echo -n -e "${C_RST}"

  fi

fi

if ${MAKEVAR_SUDO_COMMAND} docker ps --format "{{ .Names }}" | grep -q "$CONTAINER_NAME"; then

  echo -n -e "${C_GREEN}"
  echo -e "Connecting to running ${CONTAINER_NAME} container..."
  ${MAKEVAR_SUDO_COMMAND} docker exec -it "${CONTAINER_NAME}" "${CONTAINER_ENTRYPOINT}"
  echo -n -e "${C_RST}"

else

  echo -n -e "${C_YELLOW}"
  make customizations --no-print-directory
  make start-tasks --no-print-directory
  echo -n -e "${C_RST}"

  if [[ $(uname) == "Darwin" ]]; then

    echo -n -e "${C_YELLOW}"
    echo "Setting correct SSH_AUTH_SOCK for MacOS..."
    export HOST_SSH_AUTH_SOCK=/run/host-services/ssh-auth.sock
    echo -n -e "${C_RST}"

  fi

  if [[ $(uname) == "Linux" ]]; then

    echo -n -e "${C_YELLOW}"
    echo "Setting correct SSH_AUTH_SOCK for Linux..."
    export HOST_SSH_AUTH_SOCK=${SSH_AUTH_SOCK}
    echo -n -e "${C_RST}"

  fi

  ${MAKEVAR_SUDO_COMMAND} docker compose -f "${ROOT_DIR}/docker/docker-compose.yml" -f "${ROOT_DIR}/docker/docker-compose-custom.yml" -f "${ROOT_DIR}/personal/docker-compose-personal.yml" up --detach --force-recreate --remove-orphans
  ${MAKEVAR_SUDO_COMMAND} docker exec -it "${CONTAINER_NAME}" "${CONTAINER_ENTRYPOINT}"

fi

echo -n -e "${C_RST}"