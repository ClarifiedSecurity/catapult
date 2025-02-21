#!/bin/bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

# Checking if Docker is installed
if ! [[ -x "$(command -v docker)" ]]; then
  echo -n -e "${C_RED}"
  echo -e "Docker not found did you run ${C_CYAN}./install.sh${C_RED} first!"
  echo -n -e "${C_RST}"
  exit 1

fi

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

# Checking for minimum Docker version
MINIMUM_DOCKER_MAJOR_VERSION="27"
CURRENT_DOCKER_MAJOR_VERSION=$(docker --version | awk '{print $3}' | cut -d '.' -f 1)

if [[ "$CURRENT_DOCKER_MAJOR_VERSION" -lt "$MINIMUM_DOCKER_MAJOR_VERSION" ]]; then

    echo -n -e "${C_RED}"
    echo
    echo -e "Current Docker major version ${C_CYAN}$CURRENT_DOCKER_MAJOR_VERSION${C_RED} is too old!"
    echo -e "Minimum required Docker major version is ${C_CYAN}$MINIMUM_DOCKER_MAJOR_VERSION${C_RED}"
    echo -e "Your can run ${C_CYAN}./install.sh${C_RED} to install the latest Docker version for your OS."
    echo
    echo -n -e "${C_RST}"
    exit 1

fi

# Printing logo
echo "${LOGO}" | base64 -d

if [[ $1 == "stop" ]]; then

    echo -n -e "${C_YELLOW}"
    echo -e Removing existing "${CONTAINER_NAME} container..."
    echo -n -e "${C_RST}"
    DOCKER_HOST=unix:///var/run/docker.sock  rm -f "${CONTAINER_NAME}" >/dev/null
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

    # Running customizer
    "${ROOT_DIR}/scripts/general/catapult-customizer.sh"

    # Running checks
    # shellcheck disable=SC1091
    . "${ROOT_DIR}/scripts/general/checks.sh"
    # shellcheck disable=SC1091
    . "${ROOT_DIR}/scripts/general/update-catapult.sh"

    # This is to prevent errors from changed files from updating
    if [[ $CATAPULT_UPDATED == 1 ]]; then

        echo -n -e "${C_GREEN}"
        echo -e "Run ${C_CYAN}make start${C_YELLOW} again to start the container..."
        echo -n -e "${C_RST}"
        exit 0

    fi

    # Running start tasks loader
    START_TASKS_FILES="scripts/start-tasks/*.sh"
    CUSTOM_START_TASKS_FILES="custom/start-tasks/*.sh"

    # Loading custom start tasks if they are present
    if [[ -d "custom/start-tasks" ]]; then

        for custom_startfile in $CUSTOM_START_TASKS_FILES; do
        if [ -f "$custom_startfile" ]; then
            # Comment in the echo line below for better debugging
            # echo -e "\n Processing custom $custom_startfile...\n"
            $custom_startfile
        fi
        done

    fi

    for startfile in $START_TASKS_FILES; do
        if [ -f "$startfile" ]; then
        # Comment in the echo line below for better debugging
        # echo -e "\n Processing $startfile...\n"
        $startfile
        fi
    done

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

    # Also using custom Docker compose file if it exists
    if [[ -r custom/docker/docker-compose-custom.yml ]]; then

        echo -n -e "${C_YELLOW}"
        echo -e "Including docker-compose-custom.yml..."
        echo -n -e "${C_RST}"
        ${MAKEVAR_SUDO_COMMAND} docker compose -f "${ROOT_DIR}/docker/docker-compose.yml" -f "${ROOT_DIR}/custom/docker/docker-compose-custom.yml" -f "${ROOT_DIR}/personal/docker-compose-personal.yml" up --detach --force-recreate --remove-orphans

    else

        ${MAKEVAR_SUDO_COMMAND} docker compose -f "${ROOT_DIR}/docker/docker-compose.yml" -f "${ROOT_DIR}/personal/docker-compose-personal.yml" up --detach --force-recreate --remove-orphans

    fi

    ${MAKEVAR_SUDO_COMMAND} docker exec -it "${CONTAINER_NAME}" "${CONTAINER_ENTRYPOINT}"

fi

unset DOCKER_HOST

echo -n -e "${C_RST}"