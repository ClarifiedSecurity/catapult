#!/usr/bin/env bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

# shellcheck disable=SC1091
source "${MAKEVAR_ROOT_DIR}/scripts/general/checks.sh"

# Printing MAKEVAR_LOGO
printf '%b\n' "$(printf '%s' "${MAKEVAR_LOGO}" | base64 -d)"
echo

# Setting empty variables for if the custom compose file or ARA compose file is not used
DEFAULT_COMPOSE_FILE="-f ${MAKEVAR_ROOT_DIR}/defaults/docker-compose.yml"
PERSONAL_COMPOSE_FILE="-f ${MAKEVAR_ROOT_DIR}/personal/docker-compose-personal.yml"
START_WITH_CUSTOM_COMPOSE=""
START_WITH_ARA=""

# Checking if personal Docker Compose file exists and creating it if it doesn't
if [[ ! -r personal/docker-compose-personal.yml ]]; then

  cp defaults/docker-compose-personal.yml personal/docker-compose-personal.yml

fi

# Also using custom Docker compose file if it exists
if [[ -r custom/docker/docker-compose-custom.yml ]]; then
    START_WITH_CUSTOM_COMPOSE="-f ${MAKEVAR_ROOT_DIR}/custom/docker/docker-compose-custom.yml"
fi

if [[ "$MAKEVAR_ARA_ENABLE" == 1 ]]; then
    START_WITH_ARA="-f ${MAKEVAR_ROOT_DIR}/defaults/docker-compose-ara.yml"
fi

# Getting a list of all MAKEVAR_ environment variables to use with Docker Compose commands
sudo_env=()
while IFS= read -r makevar_env; do
    sudo_env+=("$makevar_env")
done < <(env | grep '^MAKEVAR_' | sort)

if [[ $1 == "stop" || $1 == "restart" ]]; then

    echo -ne "${C_YELLOW}"
    echo -e "Removing existing ${MAKEVAR_CONTAINER_NAME} container(s)..."
    echo -ne "${C_RST}"

    # Looking up all containers in the project
    # shellcheck disable=SC2086
    COMPOSE_PROJECT_CONTAINERS=$(${MAKEVAR_SUDO_COMMAND} env "${sudo_env[@]}" docker --context default compose \
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

if ${MAKEVAR_SUDO_COMMAND} docker --context default ps --format "{{ .Names }}" | grep -qx "$MAKEVAR_CONTAINER_NAME"; then

    echo -ne "${C_GREEN}"
    echo -e "Connecting to running ${MAKEVAR_CONTAINER_NAME} container..."
    ${MAKEVAR_SUDO_COMMAND} docker --context default exec -it "${MAKEVAR_CONTAINER_NAME}" "${MAKEVAR_CONTAINER_ENTRYPOINT}"
    echo -ne "${C_RST}"

else

    # Running customizer
    "${MAKEVAR_ROOT_DIR}/scripts/general/catapult-customizer.sh"

    # shellcheck disable=SC1091
    . "${MAKEVAR_ROOT_DIR}/scripts/general/update-catapult.sh"

    # This is to prevent errors from changed files from updating
    if [[ $CATAPULT_UPDATED == 1 ]]; then

        echo -ne "${C_GREEN}"
        echo -e "Run ${C_CYAN}make start${C_GREEN} again to start the container..."
        echo -ne "${C_RST}"
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

    if [[ $(uname) == "Linux" && "${MAKEVAR_HOST_USER_ID}" != 1000 ]]; then
        # Checking if the local Docker image already exists
        if [[ -z $(${MAKEVAR_SUDO_COMMAND} docker --context default images -q "${MAKEVAR_IMAGE_FULL}") ]]; then
            echo -ne "${C_YELLOW}"
            echo -e "Since the user is not 1000 (id -u), the Docker image will be built locally..."
            echo -e "Building Catapult Docker image..."
            echo -ne "${C_RST}"
            # shellcheck disable=SC2086
            ${MAKEVAR_ROOT_DIR}/scripts/general/build.sh
        fi
    fi

    if [[ "${MAKEVAR_ARA_ENABLE}" == "1" && "${MAKEVAR_ARA_LOCALHOST_ONLY}" == "1" ]]; then
        echo -ne "${C_YELLOW}"
        echo -e "ARA is enabled, you can access the ARA web interface at: ${C_CYAN}http://localhost:8000${C_YELLOW}"
        echo -ne "${C_RST}"
    elif [[ "${MAKEVAR_ARA_ENABLE}" == "1" && "${MAKEVAR_ARA_LOCALHOST_ONLY}" == "0" ]]; then
        echo -ne "${C_YELLOW}"
        echo -e "ARA is enabled, you can access over port 8000 on the host machine's IP address"
        echo -ne "${C_RST}"
    fi

    # shellcheck disable=SC2086
    ${MAKEVAR_SUDO_COMMAND} env "${sudo_env[@]}" docker --context default compose \
    ${DEFAULT_COMPOSE_FILE} \
    ${START_WITH_ARA} \
    ${START_WITH_CUSTOM_COMPOSE} \
    ${PERSONAL_COMPOSE_FILE} \
    up --detach --force-recreate --remove-orphans --no-build

    ${MAKEVAR_SUDO_COMMAND} docker --context default exec -it "${MAKEVAR_CONTAINER_NAME}" "${MAKEVAR_CONTAINER_ENTRYPOINT}"

fi

# Removing the .env file after the container has started
rm -f "${MAKEVAR_ROOT_DIR}/defaults/.env"

echo -ne "${C_RST}"
