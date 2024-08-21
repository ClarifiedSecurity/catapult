#!/bin/bash

set -e

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

echo -n -e "${C_CYAN}"

# Creating required files and folders to avoid errors
mkdir -p ./container/home/builder/.history
mkdir -p ./personal/certificates
touch ./personal/.personal_aliases

echo -n -e "${C_RST}"

# Checking if personal Docker Compose file exists and creating it if it doesn't
if [[ -r docker/docker-compose-personal.yml ]]; then

  cp docker/docker-compose-personal.yml personal/docker-compose-personal.yml
  rm -f docker/docker-compose-personal.yml

elif [[ ! -r personal/docker-compose-personal.yml ]]; then

  cp defaults/docker-compose-personal.yml personal/docker-compose-personal.yml

fi

# Checking for Docker version
MINIMUM_DOCKER_MAJOR_VERSION="26"
CURRENT_DOCKER_MAJOR_VERSION=$(docker --version | awk '{print $3}' | cut -d '.' -f 1)

if [[ "$CURRENT_DOCKER_MAJOR_VERSION" -lt "$MINIMUM_DOCKER_MAJOR_VERSION" ]]; then

    echo -n -e "${C_RED}"
    echo
    echo -e "Current Docker version $CURRENT_DOCKER_MAJOR_VERSION is too old!"
    echo -e "Minimum required Docker version is $MINIMUM_DOCKER_MAJOR_VERSION"
    echo -e "Your can run ${C_CYAN}make prepare${C_RED} to install the latest Docker version for your OS."
    echo
    echo -n -e "${C_RST}"
    exit 1

else

    echo -n

fi

echo -n -e "${C_RST}"
