#!/bin/bash

echo -n -e "${C_GREEN}"

REQUIREMENTS_FILE="/srv/requirements/requirements_nova.yml"
REMOTE_VERSION_URL=$(cat $REQUIREMENTS_FILE | grep "####" | awk '{print $4}')
REMOTE_RELEASES_URL=$(cat $REQUIREMENTS_FILE | grep "###" | awk '{print $5}')

update_collection() {

  ansible-galaxy collection install -r $REQUIREMENTS_FILE --force -p /srv/ansible

}

echo -e "Checking for nova.core updates..."
if curl github.com --connect-timeout 2 -s > /dev/null
then

  # Checking for shared roles version if MANIFEST.json exists
  if [[ -f "/srv/ansible/ansible_collections/nova/core/MANIFEST.json" ]]; then

    GALAXY_LOCAL_VERSION=$(jq -r '.collection_info.version' /srv/ansible/ansible_collections/nova/core/MANIFEST.json)

  fi

  GALAXY_REMOTE_VERSION_ROW=$(curl "$REMOTE_VERSION_URL" -s | grep "version:" | cut -d " " -f 2)
  GALAXY_REMOTE_VERSION=$(echo "$GALAXY_REMOTE_VERSION_ROW" | cut -d: -f2 | xargs)

  if [[ "$GALAXY_LOCAL_VERSION" != "$GALAXY_REMOTE_VERSION" ]]; then

    if [ "$COLLECTIONS_AUTO_UPDATE" == 1 ]; then

      update_collection

    else

      echo -n -e "${C_YELLOW}"
      echo -e "${C_YELLOW}Local nova.core collection version:${C_RST}" "$GALAXY_LOCAL_VERSION"
      echo -e "${C_YELLOW}Remote nova.core collection version:${C_RST}" "$GALAXY_REMOTE_VERSION"
      echo -e "${C_YELLOW}"
      echo -e Changelog: "$REMOTE_RELEASES_URL/tag/v$GALAXY_REMOTE_VERSION"
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