#!/bin/bash

set -e

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

# Creating required files and folders to avoid errors
mkdir -p ./container/home/builder/.history
mkdir -p ./personal/certificates
touch ./personal/.personal_aliases
touch "$HOME/.gitconfig"

# Checking if personal Docker Compose file exists and creating it if it doesn't
if [[ ! -r personal/docker-compose-personal.yml ]]; then

  cp defaults/docker-compose-personal.yml personal/docker-compose-personal.yml

fi
