#!/bin/bash

set -e

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

# Creating required files and folders to avoid errors
mkdir -p ./container/home/builder/.history
mkdir -p ./personal/certificates
touch ./personal/.personal_aliases

# Checking if personal Docker Compose file exists and creating it if it doesn't
if [[ -r docker/docker-compose-personal.yml ]]; then

  cp docker/docker-compose-personal.yml personal/docker-compose-personal.yml
  rm -f docker/docker-compose-personal.yml

elif [[ ! -r personal/docker-compose-personal.yml ]]; then

  cp defaults/docker-compose-personal.yml personal/docker-compose-personal.yml

fi
