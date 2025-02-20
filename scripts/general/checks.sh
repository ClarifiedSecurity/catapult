#!/bin/bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

echo -e -n "${C_CYAN}"

######################
# Sudo command check #
######################

# Checking that MAKEVAR_SUDO_COMMAND for MacOS is empty
if [[ "$(uname)" == "Darwin" && -n "${MAKEVAR_SUDO_COMMAND+x}" && -n "$MAKEVAR_SUDO_COMMAND" ]]; then

    echo -e "${C_RED}"
    echo -e "You are using MacOS, but MAKEVAR_SUDO_COMMAND is not empty in .makerc-personal"
    echo -e "Make sure ${C_CYAN}MAKEVAR_SUDO_COMMAND :=${C_RED} is set in ${C_CYAN}${ROOT_DIR}/personal/.makerc-personal${C_RED} file"

    echo
    read -rp "Press ENTER to continue, or Ctrl + C to cancel and set the correct MAKEVAR_SUDO_COMMAND value..."
    echo -e "${C_RST}"

fi

#######################
# MISC checks for QOL #
#######################

# Checking if ssh-agent is running
if [[ -z "${SSH_AUTH_SOCK}" ]]; then

    echo -e "${C_RED}"
    echo -e SSH agent is not running.
    echo -e Make sure ssh-agent is running.
    echo -e If you are running Catapult on remote server, make sure you have forwarded the SSH agent with the -A parameter...
    echo -e "${C_RST}"
    exit 1

fi

# Check if any keys exists in the ssh agent
if ssh-add -l >/dev/null 2>&1; then

  echo -n

else

    echo -e "${C_YELLOW}"
    echo -e There are no SSH keys in your ssh-agent.
    echo -e Some of the functionality will not work without SSH keys.
    read -rp "Press ENTER to continue, or Ctrl + C to cancel and load ssh keys to your agent..."
    echo -e "${C_RST}"

fi

echo -e -n "${C_RST}"