#!/bin/bash

echo -n -e ${C_CYAN}

# Creating required files to avoid errors
touch ./container/home/builder/.zsh_history
touch ./container/home/builder/.custom_aliases
touch .makerc-custom
touch .makerc-project
touch .makerc-personal

# Checking if user id equals 1000 on Linux
if [[ $(uname) == "Linux" ]]; then

    if [ "$(id -u)" -eq 1000 ]; then

        echo -n -e

    else

        echo -e ${C_RED}
        echo -e "Your user id is not 1000"
        echo -e "Change your used id to 1000 or build the Catapult Docker images yourself with: "
        echo -e "make build"
        echo -e ${C_RST}

    fi

fi

echo -n -e ${C_RST}