#!/usr/bin/env bash

echo -n -e "${C_GREEN}"

# Checking if this is the first run
# If so then skipping a bunch of steps for faster start
if [ ! -f /tmp/first-run ]; then

    # Running connectivity checks
    if ping -c 1 1.1.1.1 &> /dev/null; then

      echo -n -e "${C_GREEN}"
      echo -e IPv4 connectivity OK
      echo -n -e "${C_RST}"

    else

      echo -n -e "${C_RED}"
      echo -e IPv4 connectivity FAIL
      echo -n -e "${C_RST}"

    fi

    if ping -c 1 2606:4700:4700::1111 &> /dev/null; then

      echo -n -e "${C_GREEN}"
      echo -e IPv6 connectivity OK
      echo -n -e "${C_RST}"

    else

      echo -n -e "${C_RED}"
      echo -e IPv6 connectivity FAIL
      echo -n -e "${C_RST}"

    fi

    # Trusting custom certificates if they are present
    if [[ -d "/srv/custom/certificates" && "$(ls -A /srv/custom/certificates)" ]]; then

      echo -e "${C_YELLOW}Trusting custom certificates...${C_RST}"
      sudo rsync -ar /srv/custom/certificates/ /usr/local/share/ca-certificates/ --ignore-existing
      touch /tmp/trust_extra_certificates

    fi

    # Trusting personal certificates if they are present
    if [[ -d "/srv/personal/certificates" && "$(ls -A /srv/personal/certificates)" ]]; then

      echo -e "${C_YELLOW}Trusting personal certificates...${C_RST}"
      sudo rsync -ar /srv/personal/certificates/ /usr/local/share/ca-certificates/ --ignore-existing
      touch /tmp/trust_extra_certificates

    fi

    # Updating certificates if needed
    if [[ -f /tmp/trust_extra_certificates ]]; then

      sudo update-ca-certificates > /dev/null 2>/dev/null # To avoid false positive error rehash: warning: skipping ca-certificates.crt,it does not contain exactly one certificate or CRL

    fi

    # Making sure that /ssh-agent has the correct permissions, required mostly for MacOS
    # Creating the file to avoid errors when it's not present for CI pipelines for an example
    sudo touch /ssh-agent
    sudo chown -R "$(id -u)":"$(id -g)" /ssh-agent

    # Loading custom docker entrypoints if they are present
    if [[ -d "/srv/custom/docker-entrypoints" ]]; then

        DOCKER_CONTAINER_ENTRYPOINT_CUSTOM_FILES="/srv/custom/docker-entrypoints/*.sh"
        for custom_entrypoint in $DOCKER_CONTAINER_ENTRYPOINT_CUSTOM_FILES; do
            if [ -f "$custom_entrypoint" ]; then
            # Comment in the echo line below for better debugging
            # echo -e "\n Processing $custom_entrypoint...\n"
            # shellcheck disable=SC1090
            source "$custom_entrypoint"
            fi
        done

    fi

    DOCKER_CONTAINER_ENTRYPOINT_FILES="/srv/scripts/entrypoints/*.sh"
    for entrypoint in $DOCKER_CONTAINER_ENTRYPOINT_FILES; do
      if [ -f "$entrypoint" ]; then
        # Comment in the echo line below for better debugging
        # echo -e "\n Processing $entrypoint...\n"
        # shellcheck disable=SC1090
        source "$entrypoint"
      fi
    done

    # Creating first run file
    touch /tmp/first-run

fi

echo -n -e "${C_RST}"
