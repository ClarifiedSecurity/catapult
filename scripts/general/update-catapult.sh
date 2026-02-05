#!/usr/bin/env bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

echo -e -n "${C_CYAN}"

##########################
# Catapult version check #
##########################

if [[ "$MAKEVAR_FREEZE_UPDATE" != 1 ]]; then

    # Checking if github.com is reachable
    echo -n -e "${C_YELLOW}"
    echo -e "Checking if GitHub is reachable..."
    echo -n -e "${C_RST}"
    if ! curl github.com --connect-timeout 5 -s > /dev/null; then
        echo -n -e "${C_RED}"
        echo -e "Cannot check for Catapult version!"
        echo -e "GitHub is not reachable"
        echo -n -e "${C_RST}"
        exit 0;
    fi

    BRANCH="${MAKEVAR_CATAPULT_VERSION}"
    # This will get the current branch name or the tag
    LOCAL_BRANCH=$(git symbolic-ref -q --short HEAD || git describe --exact-match --tags)

    catapult_version_selector () {

        # Checking if the current branch is main or staging
        if [[ "$BRANCH" == "main" ]] || [[ "$BRANCH" == "staging" ]]; then

            git reset --hard "origin/$BRANCH"
            git switch "$BRANCH"
            git reset --hard "origin/$BRANCH"

        else

            git switch --detach "$BRANCH"

        fi

        echo -ne "${C_GREEN}"
        echo -e "Successfully changed to the ${C_CYAN}$BRANCH${C_GREEN} branch or tag"
        echo -e "Run ${C_CYAN}make start${C_GREEN} again to start the container..."
        echo -ne "${C_RST}"
        exit 0

    }

    # Checking for user is in the correct branch
    if [[ "$LOCAL_BRANCH" != "$BRANCH" ]]; then

        echo -n -e "${C_GREEN}"
        echo -e "You are not in the ${C_CYAN}$BRANCH${C_GREEN} branch or tag. Do you want to switch to there now?"
        echo -n -e "${C_RST}"
        options=(
            "yes"
            "no"
        )

        # shellcheck disable=SC2034
        select option in "${options[@]}"; do
            case "$REPLY" in
                yes|y|1) catapult_version_selector; break;;
                no|n|2) echo -e "Not changing branch"; break;;
            esac
        done

    fi

    # Catapult update function
    catapult_update () {

        if [[ "$LOCAL_BRANCH" == "$BRANCH" ]]; then

            git fetch
            git reset --hard "origin/$BRANCH" # Resetting the branch to the latest commit
            git clean --force -d # Cleaning the branch from any untracked files

        else

            git fetch origin "$BRANCH:$BRANCH"
            echo -e "${C_YELLOW}"
            echo -e "You are not in the ${C_CYAN}$BRANCH${C_YELLOW} branch, make sure to rebase your ${C_CYAN}$LOCAL_BRANCH${C_YELLOW} branch with: ${C_CYAN}git rebase -i origin/$BRANCH"
            echo -e "${C_RST}"

        fi

        echo -e "${C_GREEN}"
        echo -e "Catapult updated to version $REMOTE_VERSION"
        echo -e "${C_RST}"

        # Not pulling Catapult image if the user id is not 1000
        # In that case the image will be built later locally
        if [[ "${CONTAINER_USER_ID}" == 1000 ]]; then

            if [[ ${MAKEVAR_CATAPULT_VERSION} == "staging" ]]; then
                UPDATE_IMAGE_TAG=${MAKEVAR_CATAPULT_VERSION}
            else
                UPDATE_IMAGE_TAG=${REMOTE_VERSION}
            fi

            echo -e -n "${C_YELLOW}"
            echo -e "Updating Catapult Docker image..."
            echo -e -n "${C_RST}"
            ${MAKEVAR_SUDO_COMMAND} docker --context default pull "${MAKEVAR_CONTAINER_REGISTRY}/${MAKEVAR_IMAGE_NAME}:${UPDATE_IMAGE_TAG}"

        fi

        export CATAPULT_UPDATED=1 # Exporting the variable to be used in the make start

    }

    echo -n -e "${C_YELLOW}"
    echo -e "Checking for Catapult updates..."
    echo -n -e "${C_RST}"
    if [[ "$BRANCH" == "staging" ]]; then

        # Getting the local and remote commit hashes for the staging branch since version.yml is not updated there
        git fetch origin --quiet
        REMOTE_VERSION=$(git rev-parse --short "origin/$(git branch --show-current)")
        LOCAL_VERSION=$(git rev-parse --short HEAD)

    else

        # Checking if the latest remote version is different than the current local version
        # Using curl to get the latest version from raw file GitHub to avoid Github API rate limit
        REMOTE_VERSION=$(curl --silent "https://raw.githubusercontent.com/ClarifiedSecurity/catapult/$BRANCH/version.yml" | cut -d ' ' -f 2)
        LOCAL_VERSION=$(cat version.yml | cut -d ' ' -f 2)

    fi

    if [[ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]]; then

        if [[ "$MAKEVAR_AUTO_UPDATE" == 1 ]]; then

            echo -n -e "${C_YELLOW}"
            echo -e "Catapult version $REMOTE_VERSION is available, updating automatically..."
            if [[ "$LOCAL_BRANCH" == "main" ]]; then
                echo -e "Changelog: https://github.com/ClarifiedSecurity/catapult/releases/tag/v$REMOTE_VERSION"
            fi
            echo -n -e "${C_RST}"
            catapult_update

        else

            echo -n -e "${C_YELLOW}"
            echo -e "Catapult version $REMOTE_VERSION is available, do you want to update?"
            if [[ "$LOCAL_BRANCH" == "main" ]]; then
                echo -e "Changelog: https://github.com/ClarifiedSecurity/catapult/releases/tag/v$REMOTE_VERSION"
            fi
            echo -n -e "${C_RST}"

            options=(
                "yes"
                "no"
            )

            # shellcheck disable=SC2034
            select option in "${options[@]}"; do
                case "$REPLY" in
                    yes|y|1) catapult_update; break;;
                    no|n|2) echo -e "Not updating Catapult"; break;;
                esac
            done

        fi

    fi

else

    echo -n -e "${C_YELLOW}"
    echo -e "MAKEVAR_FREEZE_UPDATE set to 1, not offering Catapult component updates"
    echo -n -e "${C_RST}"

fi

echo -e -n "${C_RST}"