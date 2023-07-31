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

if [[ $(uname) == "Darwin" ]]; then

  echo -n -e ${C_MAGENTA}
  echo -e "Configuring MacOS..."
  echo -e "Installing MacOS packages with homebrew..."
  echo -n -e ${C_RST}
  brew install git-lfs curl

fi

if [[ $(uname) == "Linux" ]]; then

  echo -n -e ${C_MAGENTA}
  echo -e "Configuring Linux..."
  echo -n -e ${C_RST}

  if grep -q "debian" /etc/os-release; then

    echo -n -e ${C_MAGENTA}
    echo -e "Installing required deb packages..."
    echo -n -e ${C_RST}

    apt-get update
    apt-get install git-lfs curl make -y

    if [[ "${MAKEVAR_ALLOW_HOST_SSH_ACCESS}" == "true" ]]; then

      apt-get install ssh -y

    fi


  elif grep -q "arch" /etc/os-release; then

  echo -n -e ${C_MAGENTA}
	echo -e "Installing required pacman packages..."
  echo -n -e ${C_RST}

	pacman -S git git-lfs make curl --noconfirm


  else

    echo -n -e ${C_YELLOW}
    echo -e "Unsupported OS"
    echo -e "Please install git."
    echo -e "Please install git LFS for your OS and initialize it."
    echo -e "Please install curl"
    echo -e "Please install jq"
    echo -n -e ${C_RST}

  fi

fi

echo -n -e ${C_MAGENTA}
echo -e "Configuring githooks & LFS..."
echo -n -e ${C_RST}

touch ~/.gitconfig
git config core.hooksPath .githooks
git lfs install

echo -n -e ${C_MAGENTA}
echo -e "Fixing config files ownerships..."
echo -n -e ${C_RST}

chown $CONTAINER_USER_NAME ~/.gitconfig
chown -R $CONTAINER_USER_NAME .githooks
chown -R $CONTAINER_USER_NAME .git

scripts/general/configure-docker.sh
docker-registry-login

echo -n -e ${C_MAGENTA}
echo "Preparation finished"
echo -n -e ${C_RST}
