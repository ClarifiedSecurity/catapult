#!/bin/bash

set -e # exit when any command fails

echo -n -e ${C_BLUE}

# Cloninig and overwriting the customizatiins if env variable CATAPULT_CUSTOMIZER_REPO_NO_OVERWRITE is not
# Set `export CATAPULT_CUSTOMIZER_REPO_NO_OVERWRITE=true` variable temporarily to prevent overwriting your local customizations during development and testing
if [[ -z $CATAPULT_CUSTOMIZER_REPO_NO_OVERWRITE ]]; then

    # Cloning the customizer repo if it's set
    if [[ -z "${MAKEVAR_CATAPULT_CUSTOMIZER_REPO}" ]]; then

        echo -n -e

    else

        if git ls-remote ${MAKEVAR_CATAPULT_CUSTOMIZER_REPO} &> /dev/null; then

            rm -rf custom # Removing the custom directory if it exists
            echo -e "Cloning customizer repo..."
            git clone ${MAKEVAR_CATAPULT_CUSTOMIZER_REPO} custom -q --depth 1
            rm -rf custom/.git*
        else

            echo -e "${C_RED}${MAKEVAR_CATAPULT_CUSTOMIZER_REPO} repository is not available.${C_RST}"

        fi

    fi

else

    echo -n -e ${C_YELLOW}
    echo -e "CATAPULT_CUSTOMIZER_REPO_NO_OVERWRITE variable found, not overwriting custom folder"
    echo -n -e ${C_BLUE}

fi

echo -n -e ${C_BLUE}

# Copying custom .makerc files to project root if they are in the customizer repo
if [[ -d "custom/makefiles" ]]; then
    #for file in custom/makefiles/*; do
        echo -e "Copying custom .makerc files to project root..."
        cp -R custom/makefiles/. .
fi

# Copying custom aliases file from the customizer repo
if [[ -f "custom/container/.custom_aliases" ]]; then
    #for file in custom/makefiles/*; do
        echo -e "Copying .custom_aliases for container..."
        cp -f custom/container/.custom_aliases container/home/builder/.custom_aliases
fi

# Checking if custom start.yml if it exists
if [ -f custom/start.yml ]; then

    echo -e "Using custom start.yml..."
    rm -f inventories/start
    cp -R custom/start.yml inventories/start.yml

  else

    rm -f inventories/start
    cp -R defaults/start.yml inventories/start.yml

fi

# Copying Poetry files to the correct location for Dockerfile to find them
mkdir -p poetry
if [ -d custom/poetry ]; then

    echo -e "Copying custom Poetry files to poetry folder..."
    cp -R custom/poetry/. poetry

  else

    cp defaults/pyproject.toml poetry/pyproject.toml
    cp defaults/poetry.lock poetry/poetry.lock

fi

# Copying requirements files to the correct location
mkdir -p requirements
cp -R defaults/requirements*.yml requirements

# Copying custom roles & collection requirements if they exist
if [ -d custom/requirements ]; then

    echo -e "Copying custom requirements files to requirements folder..."
    cp -R custom/requirements/. requirements

fi

# Copying custom Docker compose file extension if it exists
if [ -f custom/docker/docker-compose-extra.yml ]; then

    echo -e "Using custom docker-compose-extra.yml..."
    cp custom/docker/docker-compose-extra.yml docker/docker-compose-extra.yml

  else

    cp defaults/docker-compose-extra.yml docker/docker-compose-extra.yml

fi

# Creating required folder to prevent errors
mkdir -p custom/docker-entrypoints
mkdir -p custom/start-tasks

echo -n -e ${C_RST}