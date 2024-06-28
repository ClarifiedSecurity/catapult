#!/bin/bash

set -e

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

echo -e -n "${C_CYAN}"

# Docker image pull function
docker_pull () {

# shellcheck disable=SC2034
select option in "${options[@]}"; do
    case "$REPLY" in
        yes|y|1) ${MAKEVAR_SUDO_COMMAND} docker pull "${IMAGE_FULL}"; break;;
        no|n|2) echo -e "Not pulling now"; break;;
    esac
done

}

#############################
# Docker image update check #
#############################

if [ "$MAKEVAR_FREEZE_UPDATE" != 1 ]; then

  echo -e "Checking for docker image updates..."

  # Checking if ${MAKEVAR_CONTAINER_REGISTRY} is reachable
  if curl ghcr.io --connect-timeout 5 -s > /dev/null
  then

      echo -n -e

  else

      echo -n -e "${C_RED}"
      echo -e "Cannot check for docker image version!"
      echo -e "${MAKEVAR_CONTAINER_REGISTRY} is not reachable"
      echo -n -e "${C_CYAN}"
      exit 0;

  fi

  # Checking if user id equals 1000 on Linux
  if [ "$(uname)" == "Linux" ] && [ "$(id -u)" -ne 1000 ]; then

      echo -e "${C_RED}"
      echo -e "Your user id is not 1000"
      echo -e "For most stable results run Catapult from a user with an ID of 1000"
      read -rp "Press ENTER to continue and build image locally, or Ctrl + C to cancel and change your user or user ID..."
      echo -e
      echo -e "${C_RST}"

      # Checking if local image exists and building if not
      if [[ -z "$(${MAKEVAR_SUDO_COMMAND} docker images -q "${IMAGE_FULL}")" ]]; then

        make build

      fi

    else

      # Checking if local image exists and pulling if not
      if [[ -z "$(${MAKEVAR_SUDO_COMMAND} docker images -q "${IMAGE_FULL}")" ]]; then

        # Doing nothing because Docker will pull the image if it doesn't exist
        echo -n

      else

        # Getting the local image sha256
        local_image_sha256=$(${MAKEVAR_SUDO_COMMAND} docker inspect "${IMAGE_FULL}" -f '{{.Id}}')

        # Checking if local image sha256 is present in the remote image manifest
        if ! ${MAKEVAR_SUDO_COMMAND} docker manifest inspect "${IMAGE_FULL}" -v | grep -q "$local_image_sha256"; then

          if [[ "$MAKEVAR_AUTO_UPDATE" == 1 ]]; then

            echo -n -e "${C_YELLOW}"
            echo -e "Updating Capatult image..."
            echo -n -e "${C_CYAN}"
            ${MAKEVAR_SUDO_COMMAND} docker pull "${IMAGE_FULL}"

          else

            echo -n -e "${C_YELLOW}"
            echo -e "New ${IMAGE_FULL} Docker image is available"
            echo -e "Would you like to update now?"
            echo -n -e "${C_CYAN}"

            options=(
            "yes"
            "no"
            )

            docker_pull

        fi

      fi

    fi

  fi

fi

echo -n -e "${C_RST}"