#!/bin/bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

# Cloninig and overwriting the customizations if env variable CATAPULT_CUSTOMIZER_REPO_NO_OVERWRITE is not
# Set `export CATAPULT_CUSTOMIZER_REPO_NO_OVERWRITE=true` variable temporarily to prevent overwriting your local customizations during development and testing
if [[ -z $CATAPULT_CUSTOMIZER_REPO_NO_OVERWRITE && $MAKEVAR_FREEZE_UPDATE != 1 ]]; then

    # Cloning the customizer repo if it's set
    if [[ -z "${MAKEVAR_CATAPULT_CUSTOMIZER_REPO}" ]]; then
        echo -n -e
    else

        # Extracting git clone path from MAKEVAR_CATAPULT_CUSTOMIZER_REPO in case it contains a branch
        CATAPULT_CUSTOMIZER_REPO=$(echo "${MAKEVAR_CATAPULT_CUSTOMIZER_REPO}" | awk '{print $1}')

        if git ls-remote "$CATAPULT_CUSTOMIZER_REPO" &> /dev/null; then
            rm -rf custom # Removing the custom directory if it exists
            echo -n -e "${C_YELLOW}"
            echo -e "Cloning customizer repo ${C_CYAN}${MAKEVAR_CATAPULT_CUSTOMIZER_VERSION}${C_YELLOW} version..."
            echo -n -e "${C_RST}"
            # shellcheck disable=SC2086
            git clone $MAKEVAR_CATAPULT_CUSTOMIZER_REPO -b ${MAKEVAR_CATAPULT_CUSTOMIZER_VERSION} -q --depth 1 custom
            rm -rf custom/.git*
        else
            echo -e "${C_RED}${MAKEVAR_CATAPULT_CUSTOMIZER_REPO} repository is not available.${C_RST}"
        fi
    fi
else
    if [[ -n $CATAPULT_CUSTOMIZER_REPO_NO_OVERWRITE ]]; then
        echo -n -e "${C_GREEN}"
        echo -e "CATAPULT_CUSTOMIZER_REPO_NO_OVERWRITE variable is not set, overwriting custom folder"
        echo -n -e "${C_RST}"
    fi
fi

echo -n -e "${C_RST}"