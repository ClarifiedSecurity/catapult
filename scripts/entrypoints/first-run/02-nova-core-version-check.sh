#!/bin/bash

echo -n -e "${C_GREEN}"

REPO_OWNER="${NOVA_CORE_REPO_OWNER:-ClarifiedSecurity}" # Set env var NOVA_CORE_REPO_OWNER="yourforkrepo" to override default nova.core repo owner
REPO_VERSION="${MAKEVAR_NOVA_CORE_VERSION:-${MAKEVAR_CATAPULT_VERSION:-main}}"
COLLECTION_GIT_URL="https://github.com/$REPO_OWNER/nova.core.git"
COLLECTION_NAME="nova.core"
REMOTE_VERSION_URL="https://raw.githubusercontent.com/$REPO_OWNER/nova.core/$REPO_VERSION/nova/core/galaxy.yml"
REMOTE_REPO_URL="https://github.com/$REPO_OWNER/nova.core"

if [[ "$MAKEVAR_FREEZE_UPDATE" != 1 ]]; then

    update_collection() {

        echo -n -e "${C_YELLOW}"
        echo -e "Installing $COLLECTION_NAME ${C_CYAN}v$GALAXY_REMOTE_VERSION${C_YELLOW} collection..."
        git -c advice.detachedHead=false clone "$COLLECTION_GIT_URL" --branch "$REPO_VERSION" --depth 1 --quiet /tmp/$COLLECTION_NAME
        ansible-galaxy collection install /tmp/$COLLECTION_NAME/nova --force -p /srv/ansible > /dev/null
        rm -rf /tmp/$COLLECTION_NAME

    }

    echo -e "Checking for nova.core updates..."
    if curl github.com --connect-timeout 5 -s > /dev/null; then

        # Checking for shared roles version if MANIFEST.json exists
        if [[ -f "/srv/ansible/ansible_collections/nova/core/MANIFEST.json" ]]; then

            GALAXY_LOCAL_VERSION=$(jq -r '.collection_info.version' /srv/ansible/ansible_collections/nova/core/MANIFEST.json)

        fi

        GALAXY_REMOTE_VERSION=$(curl "$REMOTE_VERSION_URL" -s | grep "version:" | cut -d " " -f 2)

        if [[ -z "$GALAXY_REMOTE_VERSION" ]]; then

            echo -n -e "${C_RED}"
            echo -e "Cannot find remote version of ${C_CYAN}$COLLECTION_NAME${C_RED} collection for branch/tag ${C_CYAN}$REPO_VERSION${C_RED}"
            echo -e "Make sure that the branch/tag actually exists in ${C_CYAN}$REMOTE_REPO_URL${C_RED}"
            echo -e "Then set the correct branch/tag with the ${C_CYAN}MAKEVAR_NOVA_CORE_VERSION${C_RED} variable"
            echo -n -e "${C_RST}"

        else

            if [[ "$GALAXY_LOCAL_VERSION" != "$GALAXY_REMOTE_VERSION" ]]; then

                if [[ "$MAKEVAR_AUTO_UPDATE" == 1 ]]; then

                    echo -n -e "${C_YELLOW}"
                    update_collection
                    echo -n -e "${C_RST}"

                else

                    echo -e "${C_YELLOW}"
                    echo -e "${C_YELLOW}Local nova.core collection version:${C_RST}" "$GALAXY_LOCAL_VERSION"
                    echo -e "${C_YELLOW}Remote nova.core collection version:${C_RST}" "$GALAXY_REMOTE_VERSION"
                    echo -e "${C_YELLOW}"

                    if [[ $REPO_VERSION == "main" ]]; then

                        echo -e Changelog: "$REMOTE_REPO_URL/releases/tag/v$GALAXY_REMOTE_VERSION"

                    fi

                    ask_confirm() {
                        while true; do
                            echo -n -e "${C_YELLOW}"
                            echo -n -e "Would you like to update now (y/n)?"
                            echo -e "${C_RST}"
                            read -r response
                            case $response in
                            [Yy]*|yes)
                                update_collection
                                break
                                ;;
                            [Nn]*|no)
                                echo -n -e "${C_YELLOW}"
                                echo -e "Not updating now"
                                echo -n -e "${C_RST}"
                                break
                                ;;
                            *)
                                echo -n -e "${C_RED}"
                                echo -e "Unknown response. Please answer yes or no."
                                echo -n -e "${C_RST}"
                                ;;
                            esac
                        done
                    }

                    ask_confirm

                fi

            fi

        fi

        unset GALAXY_LOCAL_VERSION
        unset GALAXY_REMOTE_VERSION

    else

        echo -n -e "${C_RED}"
        echo -e Cannot check for nova.core version!
        echo -e github.com is not reachable
        echo -n -e "${C_RST}"

    fi

    echo -n -e "${C_RST}"

fi