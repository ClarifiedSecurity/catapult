#!/bin/bash

echo -n -e ${C_CYAN}

# Docker image pull function
docker_pull () {

select option in "${options[@]}"; do
    case "$REPLY" in
        yes) ${MAKEVAR_SUDO_COMMAND} docker pull ${IMAGE_FULL}; break;;
        no) echo -e "Not pulling now"; break;;
        y) ${MAKEVAR_SUDO_COMMAND} docker pull ${IMAGE_FULL}; break;;
        n) echo -e "Not pulling now"; break;;
        1) ${MAKEVAR_SUDO_COMMAND} docker pull ${IMAGE_FULL}; break;;
        2) echo -e "Not pulling now"; break;;
    esac
done

}

# Chcking for docker image updates if ${MAKEVAR_CONTAINER_REGISTRY} is defined
if [[ -z "${MAKEVAR_CONTAINER_REGISTRY}" ]]; then

  echo -n -e ${C_RED}
  echo -e "Cannot check for docker image version, MAKEVAR_CONTAINER_REGISTRY is not defined in .makerc-vars!"
  echo -n -e ${C_CYAN}
  exit 0;

fi

# Checking if ${MAKEVAR_CONTAINER_REGISTRY} is reachable
http_code=$(curl -L https://${MAKEVAR_CONTAINER_REGISTRY} --write-out "%{http_code}" -s -o /dev/null)

if [[ $http_code == 200 ]]
then

    echo -n -e

else

    echo -n -e ${C_RED}
    echo -e "Cannot check for docker image version!"
    echo -e "${MAKEVAR_CONTAINER_REGISTRY} is not reachable"
    echo -n -e ${C_CYAN}
    exit 0;

fi

# Checking if local image exists and pulling if not
if [[ -z "$(${MAKEVAR_SUDO_COMMAND} docker images -q ${IMAGE_FULL})" ]]; then

    echo -n -e ${C_YELLOW}
    echo -e "Local ${IMAGE_FULL} docker image not found"
    echo -e "Would you like to pull it now?"
    echo -n -e ${C_CYAN}
    options=(
        "yes"
        "no"
    )
    docker_pull


else

    # Getting the local image sha256
    local_image_sha256=$(${MAKEVAR_SUDO_COMMAND} docker inspect ${IMAGE_FULL} -f '{{.Id}}')

    # Checking if local image sha256 is present in the remote image manifest
    if [[ -z $(${MAKEVAR_SUDO_COMMAND} docker manifest inspect ${IMAGE_FULL} -v | grep $local_image_sha256) ]]; then

        echo -n -e ${C_YELLOW}
        echo -e "New ${IMAGE_FULL} docker image is available"
        echo -e "Would you like to update now?"
        echo -n -e ${C_CYAN}
        options=(
        "yes"
        "no"
        )
        docker_pull

    fi

fi

echo -n -e ${C_RST}