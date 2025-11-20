#!/usr/bin/env bash

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

# Setting correct SSH_AUTH_SOCK for MacOS and Linux
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

# Setting empty variables for if the custom compose file or ARA compose file is not used
DEFAULT_COMPOSE_FILE="-f ${ROOT_DIR}/defaults/docker-compose.yml"
PERSONAL_COMPOSE_FILE="-f ${ROOT_DIR}/personal/docker-compose-personal.yml"
START_WITH_CUSTOM_COMPOSE=""
START_WITH_ARA=""

# Checking if personal Docker Compose file exists and creating it if it doesn't
if [[ ! -r personal/docker-compose-personal.yml ]]; then

  cp defaults/docker-compose-personal.yml personal/docker-compose-personal.yml

fi

# Also using custom Docker compose file if it exists
if [[ -r custom/docker/docker-compose-custom.yml ]]; then
    START_WITH_CUSTOM_COMPOSE="-f ${ROOT_DIR}/custom/docker/docker-compose-custom.yml"
fi

if [[ "$MAKEVAR_ARA_ENABLE" == 1 ]]; then
    START_WITH_ARA="-f ${ROOT_DIR}/defaults/docker-compose-ara.yml"
fi

# Printing logo
echo "${LOGO}" | base64 -d

if [[ $1 == "stop" || $1 == "restart" ]]; then

    echo -n -e "${C_YELLOW}"
    echo -e Removing existing "${CONTAINER_NAME} container(s)..."
    echo -n -e "${C_RST}"

    # Looking up all containers in the project
    # shellcheck disable=SC2086
    COMPOSE_PROJECT_CONTAINERS=$(${MAKEVAR_SUDO_COMMAND} docker --context default compose \
    ${DEFAULT_COMPOSE_FILE} \
    ${START_WITH_ARA} \
    ${START_WITH_CUSTOM_COMPOSE} \
    ${PERSONAL_COMPOSE_FILE} \
    ps --format "{{ .Names }}")

    # Using grep to check if the container exists and removing it because it's considerably faster than docker compose down
    for container in $COMPOSE_PROJECT_CONTAINERS; do
        if ${MAKEVAR_SUDO_COMMAND} docker --context default ps --format "{{ .Names }}" | grep -qx "$container"; then
            ${MAKEVAR_SUDO_COMMAND} docker --context default rm --force "$container" > /dev/null
        fi
    done

    if [[ $1 == "stop" ]]; then
        exit 0
    fi
fi

if ${MAKEVAR_SUDO_COMMAND} docker --context default ps --format "{{ .Names }}" | grep -qx "$CONTAINER_NAME"; then

    echo -n -e "${C_GREEN}"
    echo -e "Connecting to running ${CONTAINER_NAME} container..."
    ${MAKEVAR_SUDO_COMMAND} docker --context default exec -it "${CONTAINER_NAME}" "${CONTAINER_ENTRYPOINT}"
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
        echo -e "Run ${C_CYAN}make start${C_GREEN} again to start the container..."
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

    if [[ $(uname) == "Linux" && "${CONTAINER_USER_ID}" != 1000 ]]; then
        # Checking if the local Docker image already exists
        if [[ -z $(${MAKEVAR_SUDO_COMMAND} docker --context default images -q "${IMAGE_FULL}") ]]; then
            echo -ne "${C_YELLOW}"
            echo -e "Since the user is not 1000 (id -u), the Docker image will be built locally..."
            echo -e "Building Catapult Docker image..."
            echo -ne "${C_RST}"
            # shellcheck disable=SC2086
            ${ROOT_DIR}/scripts/general/build.sh
        fi
    fi

    # shellcheck disable=SC2086
    ${MAKEVAR_SUDO_COMMAND} docker --context default compose \
    ${DEFAULT_COMPOSE_FILE} \
    ${START_WITH_ARA} \
    ${START_WITH_CUSTOM_COMPOSE} \
    ${PERSONAL_COMPOSE_FILE} \
    up --detach --force-recreate --remove-orphans

    ${MAKEVAR_SUDO_COMMAND} docker --context default exec -it "${CONTAINER_NAME}" "${CONTAINER_ENTRYPOINT}"

fi

echo -n -e "${C_RST}"
