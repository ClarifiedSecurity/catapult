#!/bin/bash

echo -n -e "${C_GREEN}"

COLLECTION_GIT_URL="https://github.com/ClarifiedSecurity/nova.core.git"
COLLECTION_NAME="nova.core"
REMOTE_VERSION_URL="https://raw.githubusercontent.com/ClarifiedSecurity/nova.core/$MAKEVAR_CATAPULT_VERSION/nova/core/galaxy.yml"
REMOTE_RELEASES_URL="https://github.com/ClarifiedSecurity/nova.core/releases"

if [ "$MAKEVAR_FREEZE_UPDATE" != 1 ]; then

  update_collection() {

    echo -e "Downloading $COLLECTION_NAME collection..."
    git clone $COLLECTION_GIT_URL --branch "$MAKEVAR_CATAPULT_VERSION" --depth 1 --quiet /tmp/$COLLECTION_NAME
    ansible-galaxy collection install /tmp/$COLLECTION_NAME/nova --force -p /srv/ansible
    rm -rf /tmp/$COLLECTION_NAME

  }

  echo -e "Checking for nova.core updates..."
  if curl github.com --connect-timeout 5 -s > /dev/null
  then

    # Checking for shared roles version if MANIFEST.json exists
    if [[ -f "/srv/ansible/ansible_collections/nova/core/MANIFEST.json" ]]; then

      GALAXY_LOCAL_VERSION=$(jq -r '.collection_info.version' /srv/ansible/ansible_collections/nova/core/MANIFEST.json)

    fi

    GALAXY_REMOTE_VERSION_ROW=$(curl "$REMOTE_VERSION_URL" -s | grep "version:" | cut -d " " -f 2)
    GALAXY_REMOTE_VERSION=$(echo "$GALAXY_REMOTE_VERSION_ROW" | cut -d: -f2 | xargs)

    if [[ "$GALAXY_LOCAL_VERSION" != "$GALAXY_REMOTE_VERSION" ]]; then

      if [ "$MAKEVAR_AUTO_UPDATE" == 1 ]; then

        echo -n -e "${C_YELLOW}"
        update_collection
        echo -n -e "${C_RST}"

      else

        echo -e "${C_YELLOW}"
        echo -e "${C_YELLOW}Local nova.core collection version:${C_RST}" "$GALAXY_LOCAL_VERSION"
        echo -e "${C_YELLOW}Remote nova.core collection version:${C_RST}" "$GALAXY_REMOTE_VERSION"
        echo -e "${C_YELLOW}"
        if [[ $MAKEVAR_CATAPULT_VERSION == "main" ]]; then

          echo -e Changelog: "$REMOTE_RELEASES_URL/tag/v$GALAXY_REMOTE_VERSION"

        fi
        echo -e "Would you like to update now?"
        echo -n -e "${C_RST}"
        options=(
          "yes"
          "no"
        )

        # shellcheck disable=SC2034
        select option in "${options[@]}"; do
        echo -n -e "${C_YELLOW}"
            case "$REPLY" in
                yes|y|1) update_collection; break;;
                no|n|2) echo -e "Not updating now"; break;;
            esac
        echo -n -e "${C_RST}"
        done

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