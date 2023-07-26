#!/bin/bash

echo -n -e ${C_CYAN}

# If ALLOW_HOST_SSH_ACCESS is set to true, then we will allow SSH access to the host from the container.
if [[ "${MAKEVAR_ALLOW_HOST_SSH_ACCESS}" == "true" ]]; then

  # Creating IPTables rule to allow SSH access to the host from the container, if iptables is installed.
  if ! [ -x "$(command -v iptables)" ]; then

      echo -e "Iptables is not installed..."

    elif [[ $(uname) == "Linux" ]]; then

      host_ssh_rule="INPUT -p tcp -m tcp -s ${CONTAINER_NETWORK_IPV4_SUBNET} --dport 22 -j ACCEPT"

      if ${MAKEVAR_SUDO_COMMAND} iptables -S | grep -q "$host_ssh_rule"; then

        echo -e "Host SSH access already enabled..."

      else

        echo -e "Enabling host SSH access only from the container network..."
        ${MAKEVAR_SUDO_COMMAND} iptables -I $host_ssh_rule

      fi

      echo -e "Starting SSH server on $(hostname)..."

      if grep -q "arch" /etc/os-release; then

        ${MAKEVAR_SUDO_COMMAND} systemctl start sshd

      else

        ${MAKEVAR_SUDO_COMMAND} systemctl start ssh

      fi

  fi

fi

