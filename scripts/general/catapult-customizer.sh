#!/bin/bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

echo -n -e "${C_BLUE}"

# Cloninig and overwriting the customizations if env variable CATAPULT_CUSTOMIZER_REPO_NO_OVERWRITE is not
# Set `export CATAPULT_CUSTOMIZER_REPO_NO_OVERWRITE=true` variable temporarily to prevent overwriting your local customizations during development and testing
if [[ -z $CATAPULT_CUSTOMIZER_REPO_NO_OVERWRITE ]]; then

    # Cloning the customizer repo if it's set
    if [[ -z "${MAKEVAR_CATAPULT_CUSTOMIZER_REPO}" ]]; then

        echo -n -e

    else

        # Extracting git clone path from MAKEVAR_CATAPULT_CUSTOMIZER_REPO in case it contains a branch
        CATAPULT_CUSTOMIZER_REPO=$(echo "${MAKEVAR_CATAPULT_CUSTOMIZER_REPO}" | awk '{print $1}')

        if git ls-remote "$CATAPULT_CUSTOMIZER_REPO" &> /dev/null; then

            rm -rf custom # Removing the custom directory if it exists
            echo -e "Cloning customizer repo..."
            # shellcheck disable=SC2086
            git clone $MAKEVAR_CATAPULT_CUSTOMIZER_REPO -q --depth 1 custom
            rm -rf custom/.git*
        else

            echo -e "${C_RED}${MAKEVAR_CATAPULT_CUSTOMIZER_REPO} repository is not available.${C_RST}"

        fi

    fi

else

    echo -n -e "${C_YELLOW}"
    echo -e "CATAPULT_CUSTOMIZER_REPO_NO_OVERWRITE variable found, not overwriting custom folder"
    echo -n -e "${C_BLUE}"

fi

echo -n -e "${C_BLUE}"

# Checking if custom start.yml if it exists
if [ -f custom/start.yml ]; then

    echo -e "Using custom start.yml..."
    rm -f inventories/start
    cp -R custom/start.yml inventories/start.yml

  else

    rm -f inventories/start
    cp -R defaults/start.yml inventories/start.yml

fi

# Copying requirements files to the correct location
mkdir -p requirements
rm -f requirements/*
cp -R defaults/requirements*.yml requirements

# Copying custom roles & collection requirements if they exist
if [ -d custom/requirements ]; then

    echo -e "Copying custom requirements files to requirements folder..."
    cp -R custom/requirements/. requirements

fi

# Copying custom Docker compose file extension if it exists
if [[ -r custom/docker/docker-compose-extra.yml ]]; then

    echo -e "Using extended docker-compose-extra.yml..."
    echo -n -e "${C_MAGENTA}"
    echo -e "WARNING docker-compose-extra.yml file name will be deprecated."
    echo -e "Rename it to docker-compose-custom.yml in your $MAKEVAR_CATAPULT_CUSTOMIZER_REPO project!"
    echo -n -e "${C_BLUE}"
    cp custom/docker/docker-compose-extra.yml docker/docker-compose-custom.yml
    rm -f docker/docker-compose-extra.yml

  elif [[ -r custom/docker/docker-compose-custom.yml ]]; then

    echo -e "Using extended docker-compose-custom.yml..."
    cp custom/docker/docker-compose-custom.yml docker/docker-compose-custom.yml
    rm -f docker/docker-compose-extra.yml

  else

    cp defaults/docker-compose-custom.yml docker/docker-compose-custom.yml

fi

# Creating required folder to prevent errors
mkdir -p custom/docker-entrypoints
mkdir -p custom/start-tasks

echo -n -e "${C_RST}"