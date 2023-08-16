#!/bin/bash

set -e # exit when any command fails

# Logging into Docker registry if it's defined
docker-registry-login() {

echo -n -e ${C_MAGENTA}
echo -e "Using ${MAKEVAR_CONTAINER_REGISTRY} as Docker registry"
echo -n -e ${C_RST}

if [[ "${MAKEVAR_CONTAINER_REGISTRY_REQUIRES_AUTH}" != "false" ]]; then

  if ping -c 1 ${MAKEVAR_CONTAINER_REGISTRY} &> /dev/null
  then

    echo -e "\nLogging into ${MAKEVAR_CONTAINER_REGISTRY}, enter your credentials:"
    make docker-login --no-print-directory

  else

    echo "------";
    echo "Cannot login to ${MAKEVAR_CONTAINER_REGISTRY}!"
    echo "${MAKEVAR_CONTAINER_REGISTRY} is not reachable"

    echo "------";
  fi

fi

}

scripts/general/configure-docker.sh

echo -e ${C_YELLOW}
echo -e "Do you want Catapult to install and configure KeePassXC database and key?"

options=(
  "Yes it's fine"
  "No, already have my own database and key"
)

select option in "${options[@]}"; do
    case "$REPLY" in
        yes) scripts/general/configure-keepassxc.sh; break;;
        no) echo -e "Make sure you fill out the required values in ${ROOT_DIR}/.makerc-vars"; break;;
        y) scripts/general/configure-keepassxc.sh; break;;
        n) echo -e "Make sure you fill out the required values in ${ROOT_DIR}/.makerc-vars"; break;;
        1) scripts/general/configure-keepassxc.sh; break;;
        2) echo -e "Make sure you fill out the required values in ${ROOT_DIR}/.makerc-vars"; break;;
    esac
done

echo -n -e ${C_RST}

echo -n -e ${C_MAGENTA}
echo "Install finished successfully"
echo -n -e ${C_RST}
