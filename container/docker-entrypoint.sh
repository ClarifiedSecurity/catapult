#!/usr/bin/env bash

# shellcheck disable=SC1091
source /srv/scripts/general/colors.sh

echo -n -e "${C_GREEN}"

# Activating Python virtual environment
export PATH=$HOME/.cargo/bin:$PATH
# shellcheck disable=SC1091
source "$HOME/.venv/bin/activate"

# Making sure that /ssh-agent has the correct permissions, required mostly for MacOS
sudo chown -R "$(id -u)":"$(id -g)" /ssh-agent

# Secrets unlocker script
# Can also be used with ctp secrets unlock
source /srv/scripts/general/secrets-unlock.sh

# Checking if this is the first run
# If so then skipping a bunch of steps for better performance
if [ ! -f /tmp/first-run ]; then

    # Creating first run file
    touch /tmp/first-run

    # Running connectivity checks
    /srv/scripts/general/connectivity-checks.sh

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

    DOCKER_CONTAINER_ENTRYPOINT_CUSTOM_FILES="/srv/custom/docker-entrypoints/*.sh"
    for custom_entrypoint in $DOCKER_CONTAINER_ENTRYPOINT_CUSTOM_FILES; do
      if [ -f "$custom_entrypoint" ]; then
        # Comment in the echo line below for better debugging
        # echo -e "\n Processing $custom_entrypoint...\n"
        # shellcheck disable=SC1090
        source "$custom_entrypoint"
      fi
    done

    DOCKER_CONTAINER_ENTRYPOINT_FILES="/srv/scripts/entrypoints/*.sh"
    for entrypoint in $DOCKER_CONTAINER_ENTRYPOINT_FILES; do
      if [ -f "$entrypoint" ]; then
        # Comment in the echo line below for better debugging
        # echo -e "\n Processing $entrypoint...\n"
        # shellcheck disable=SC1090
        source "$entrypoint"
      fi
    done

fi

# Running inventory selection script
source /srv/scripts/general/select-inventory.sh

echo -n -e "${C_RST}"

exec zsh