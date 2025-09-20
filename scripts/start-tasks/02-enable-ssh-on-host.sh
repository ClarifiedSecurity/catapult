#!/usr/bin/env bash

set -e

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

# If ALLOW_HOST_SSH_ACCESS is set to true, then we will allow SSH access to the host from the container.
if [[ "${MAKEVAR_ALLOW_HOST_SSH_ACCESS}" == "true" ]]; then

  # Only supported on Linux.
  if [[ $(uname) == "Linux" ]]; then

    echo -n -e "${C_YELLOW}"
    echo -e "Starting SSH server on $(hostname)..."
    echo -n -e "${C_RST}"

    if grep -q "arch" /etc/os-release; then

      ${MAKEVAR_SUDO_COMMAND} systemctl start sshd

    else

      ${MAKEVAR_SUDO_COMMAND} systemctl start ssh

    fi

  fi

fi
