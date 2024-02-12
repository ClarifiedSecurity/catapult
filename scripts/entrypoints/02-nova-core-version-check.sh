#!/bin/bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source /srv/scripts/general/colors.sh

echo -n -e ${C_GREEN}

REQUIREMENTS_FILE="/srv/requirements/requirements_nova.yml"
REMOTE_URL=$(cat $REQUIREMENTS_FILE | grep "version_check_url:" | awk '{print $2}')

if ping -c 1 github.com &> /dev/null
then

  # Checking for shared roles version if MANIFEST.json exists
  if [[ -f "/srv/ansible/ansible_collections/nova/core/MANIFEST.json" ]]; then

    galaxy_local_version=$(cat /srv/ansible/ansible_collections/nova/core/MANIFEST.json | jq -r '.collection_info.version')

  fi

  galaxy_remote_version_row=$(curl $REMOTE_URL -s | grep "version:" | cut -d " " -f 2)
  galaxy_remote_version=$( echo $galaxy_remote_version_row | cut -d: -f2 | xargs )
  galaxy_local_version_patch=$( echo $galaxy_local_version | cut -d. -f3 )
  galaxy_remote_version_patch=$( echo $galaxy_remote_version | cut -d. -f3 )

  if [[ "$galaxy_local_version" != "$galaxy_remote_version" ]]; then

    echo -n -e ${C_YELLOW}
    echo -e "${C_YELLOW}Local nova.core collection version:${C_RST}" $galaxy_local_version
    echo -e "${C_YELLOW}Remote nova.core collection version:${C_RST}" $galaxy_remote_version
    echo -n -e ${C_YELLOW}
    echo -e "Remote nova.core collection differs from local"
    echo -e "Would you like to update now?"
    echo -n -e ${C_RST}
    options=(
      "yes"
      "no"
    )

    select option in "${options[@]}"; do
    echo -n -e ${C_YELLOW}
        case "$REPLY" in
            yes|y|1) ansible-galaxy collection install -r $REQUIREMENTS_FILE --force -p /srv/ansible; break;;
            no|n|2) echo -e "Not updating now"; break;;
        esac
    echo -n -e ${C_RST}
    done
  fi

  unset galaxy_local_version
  unset galaxy_remote_version

else

  echo -n -e ${C_RED}
  echo -e Cannot check for nova.core version!
  echo -e github.com is not reachable
  echo -n -e ${C_RST}

fi