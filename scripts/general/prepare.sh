#!/bin/bash

set -e # exit when any command fails

echo -n -e ${C_MAGENTA}

# Logging into Docker registry if it's defined
docker-registry-login() {

echo -n -e ${C_MAGENTA}

echo -e "Using ${MAKEVAR_CONTAINER_REGISTRY} as Docker registry"

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

  echo "Configuring MacOS..."

  echo "Installing MacOS packages with homebrew..."
  brew install git-lfs curl

fi

if [[ $(uname) == "Linux" ]]; then

  echo "Configuring Linux..."

  if grep -q "debian" /etc/os-release; then

    echo "Installing required deb packages..."
    apt-get update
    apt-get install git-lfs curl make -y

    if [[ "${MAKEVAR_ALLOW_HOST_SSH_ACCESS}" == "true" ]]; then

      apt-get install ssh -y

    fi


  elif grep -q "arch" /etc/os-release; then

	echo "Installing required pacman packages..."
	pacman -S git git-lfs make curl --noconfirm


  else

    echo "Unsupported OS"
    echo "Please install git."
    echo "Please install git LFS for your OS and initialize it."
    echo "Please install curl"
    echo "Please install jq"

  fi

fi

echo -e "Configuring githooks & LFS..."
touch ~/.gitconfig
git config core.hooksPath .githooks
git lfs install

echo -e "Fixing config files ownerships..."
chown $CONTAINER_USER_NAME ~/.gitconfig
chown -R $CONTAINER_USER_NAME .githooks
chown -R $CONTAINER_USER_NAME .git

scripts/general/configure-docker.sh
docker-registry-login

echo "Preparation finished"

echo -n -e ${C_RST}
