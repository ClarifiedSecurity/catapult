#!/usr/bin/env bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

# Cloning and overwriting the customizations if env variable CATAPULT_CUSTOMIZER_REPO_NO_OVERWRITE is not
# Set `export CATAPULT_CUSTOMIZER_REPO_NO_OVERWRITE=true` variable temporarily to prevent overwriting your local customizations during development and testing
if [[ -z ${CATAPULT_CUSTOMIZER_REPO_NO_OVERWRITE} && ${MAKEVAR_FREEZE_UPDATE} == 0 ]]; then

    # Cloning the customizer repo if it's set
    if [[ -n "${MAKEVAR_CATAPULT_CUSTOMIZER_REPO}" ]]; then

        if [[ -f custom/checksum ]]; then
            CATAPULT_CUSTOMIZER_LOCAL_VERSION=$(cat custom/checksum)
        fi
        CATAPULT_CUSTOMIZER_REMOTE_VERSION=$(git ls-remote "${MAKEVAR_CATAPULT_CUSTOMIZER_REPO}" \
        refs/heads/"${MAKEVAR_CATAPULT_CUSTOMIZER_VERSION}" 2>/dev/null | awk '{print $1}' | cut -c 1-7)

        echo -n -e "${C_YELLOW}"
        echo -e "Checking for Catapult Customizer updates..."
        echo -n -e "${C_RST}"
        if [[ -n "$CATAPULT_CUSTOMIZER_REMOTE_VERSION" ]]; then


            if [[ "$CATAPULT_CUSTOMIZER_LOCAL_VERSION" != "$CATAPULT_CUSTOMIZER_REMOTE_VERSION" ]]; then

                rm -rf custom # Removing the custom directory if it exists
                echo -n -e "${C_YELLOW}"
                echo -e "Cloning customizer repo ${C_CYAN}${MAKEVAR_CATAPULT_CUSTOMIZER_VERSION}${C_YELLOW} version..."
                echo -n -e "${C_RST}"
                # shellcheck disable=SC2086
                git clone $MAKEVAR_CATAPULT_CUSTOMIZER_REPO -b ${MAKEVAR_CATAPULT_CUSTOMIZER_VERSION} -q --depth 1 custom
                git -C custom rev-parse --short HEAD > custom/checksum
                rm -rf custom/.git*
            fi

        else
            echo -e "${C_RED}${MAKEVAR_CATAPULT_CUSTOMIZER_REPO} repository is not available!${C_RST}"
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
