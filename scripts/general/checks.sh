#!/usr/bin/env bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

echo -e -n "${C_CYAN}"

#################
# SSH_AUTH_SOCK #
#################

# Checking if ssh-agent is running
if [[ -z "${SSH_AUTH_SOCK}" ]]; then
    echo -ne "${C_YELLOW}"
    echo -e SSH agent is not running.
    echo -e Make sure ssh-agent is running.
    echo -e All of the functionality will not work properly without the SSH agent.
    echo -e If you are running Catapult on remote server, make sure you have forwarded the SSH agent:
    echo -e "example: ssh -A user@remote-server"
    read -rp "Press ENTER to continue, or Ctrl + C to cancel..."
    echo -e "${C_RST}"

    # These are needed for the advanced edge case where the SSH agent is not running but we still want to start Catapult
    touch /tmp/ssh-agent-placeholder
    export SSH_AUTH_SOCK="/tmp/ssh-agent-placeholder"
fi

# Check if any keys exists in the ssh agent
if ssh-add -l >/dev/null 2>&1; then
    echo -n
else
    echo -ne "${C_YELLOW}"
    echo -e There are no SSH keys in your ssh-agent.
    echo -e Some of the functionality will not work without SSH keys.
    read -rp "Press ENTER to continue, or Ctrl + C to cancel and load ssh keys to your agent..."
    echo -e "${C_RST}"
fi

if [[ $(uname) == "Darwin" ]]; then
    # Checking if SSH_AUTH_SOCK is the default MacOS socket
    if [[ "$SSH_AUTH_SOCK" == */private/tmp/* || "$SSH_AUTH_SOCK" == /var/run/com.apple.launchd.*/Listeners ]]; then
        echo -ne "${C_YELLOW}"
        echo "Setting correct SSH_AUTH_SOCK for MacOS..."
        export MAKEVAR_HOST_SSH_AUTH_SOCK=/run/host-services/ssh-auth.sock
        echo -ne "${C_RST}"
    # If not the default one then some type of password manager is likely being used, so we will just use the SSH_AUTH_SOCK from the environment variable
    else
        echo -ne "${C_YELLOW}"
        echo "Using SSH_AUTH_SOCK from environment variable for MacOS..."
        export MAKEVAR_HOST_SSH_AUTH_SOCK="${SSH_AUTH_SOCK}"
        echo -ne "${C_RST}"
    fi
elif [[ $(uname) == "Linux" ]]; then
    echo -ne "${C_YELLOW}"
    echo "Setting correct SSH_AUTH_SOCK for Linux..."
    export MAKEVAR_HOST_SSH_AUTH_SOCK=${SSH_AUTH_SOCK}
    echo -ne "${C_RST}"
fi

#################
# Docker checks #
#################

# Fixing personal Docker compose file service names
if [[ -d "${MAKEVAR_ROOT_DIR}/personal" ]]; then
    while IFS= read -r -d '' personal_file; do
        if grep -q "\${CONTAINER_PROJECT_NAME}" "$personal_file"; then
            sed -i.bak "s/\${CONTAINER_PROJECT_NAME}/\${MAKEVAR_CONTAINER_PROJECT_NAME}/g" "$personal_file"
            rm -f "${personal_file}.bak"
        fi
    done < <(find "${MAKEVAR_ROOT_DIR}/personal" -type f -print0)
fi

# Checking if Docker is installed
if ! [[ -x "$(command -v docker)" ]]; then

    echo -ne "${C_RED}"
    echo -e "Docker not found did you run ${C_CYAN}./install.sh${C_RED} first!"
    echo -ne "${C_RST}"
    exit 1

fi

MINIMUM_DOCKER_MAJOR_VERSION="27"
CURRENT_DOCKER_MAJOR_VERSION=$(docker --version | awk '{print $3}' | cut -d '.' -f 1)

if [[ "$CURRENT_DOCKER_MAJOR_VERSION" -lt "$MINIMUM_DOCKER_MAJOR_VERSION" ]]; then
    echo -ne "${C_RED}"
    echo
    echo -e "Current Docker major version ${C_CYAN}$CURRENT_DOCKER_MAJOR_VERSION${C_RED} is too old!"
    echo -e "Minimum required Docker major version is ${C_CYAN}$MINIMUM_DOCKER_MAJOR_VERSION${C_RED}"
    echo -e "Your can run ${C_CYAN}./install.sh${C_RED} to install the latest Docker version for your OS."
    echo
    echo -ne "${C_RST}"
    exit 1
fi

######################
# Sudo command check #
######################

# Checking that MAKEVAR_SUDO_COMMAND for MacOS is empty
if [[ "$(uname)" == "Darwin" && -n "${MAKEVAR_SUDO_COMMAND+x}" && -n "$MAKEVAR_SUDO_COMMAND" ]]; then
    echo -e "${C_RED}"
    echo -e "You are using MacOS, but MAKEVAR_SUDO_COMMAND is not empty in .makerc-personal"
    echo -e "Make sure ${C_CYAN}MAKEVAR_SUDO_COMMAND :=${C_RED} is set in ${C_CYAN}${MAKEVAR_ROOT_DIR}/personal/.makerc-personal${C_RED} file"
    echo
    read -rp "Press ENTER to continue, or Ctrl + C to cancel and set the correct MAKEVAR_SUDO_COMMAND value..."
    echo -e "${C_RST}"
fi

echo -e -n "${C_RST}"