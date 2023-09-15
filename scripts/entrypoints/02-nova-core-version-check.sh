#!/bin/bash

C_RED="\033[31m"
C_GREEN="\033[32m"
C_YELLOW="\033[33m"
C_RST="\033[0m"

echo -n -e ${C_GREEN}

if ping -c 1 github.com &> /dev/null
then

  # Checking for shared roles version if MANIFEST.json exists
  if [[ -f "/srv/ansible/ansible_collections/nova/core/MANIFEST.json" ]]; then

    galaxy_local_version=$(cat /srv/ansible/ansible_collections/nova/core/MANIFEST.json | jq -r '.collection_info.version')

  fi

  galaxy_remote_version_row=$(curl https://raw.githubusercontent.com/novateams/nova.core/main/nova/core/galaxy.yml -s | grep "version:" | cut -d " " -f 2)
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
            yes) ansible-galaxy collection install -r /srv/requirements/requirements_custom.yml --force -p /srv/ansible; break;;
            no) echo -e "Not updating now"; break;;
            y) ansible-galaxy collection install -r /srv/requirements/requirements_custom.yml --force -p /srv/ansible; break;;
            n) echo -e "Not updating now"; break;;
            1) ansible-galaxy collection install -r /srv/requirements/requirements_custom.yml --force -p /srv/ansible; break;;
            2) echo -e "Not updating now"; break;;
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