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
  echo -e "Installing MacOS packages with homebrew..."
  echo -n -e ${C_RST}
  brew install git-lfs curl md5sha1sum

fi

if [[ $(uname) == "Linux" ]]; then

  if grep -q "debian" /etc/os-release; then

    echo -n -e ${C_MAGENTA}
    echo -e "Installing required deb packages..."
    echo -n -e ${C_RST}

    apt-get update
    apt-get install git-lfs curl make gpg -y

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

echo -e ${C_YELLOW}
echo -e "Do you want Catapult to install and configure KeePassXC database and key?"

options=(
  "Yes it's fine"
  "No, already have my own database and key"
)

select option in "${options[@]}"; do
    case "$REPLY" in
        yes) scripts/general/configure-keepassxc.sh; break;;
        no) echo -e "Not configuring KeePassXC"; break;;
        y) scripts/general/configure-keepassxc.sh; break;;
        n) echo -e "Not configuring KeePassXC"; break;;
        1) scripts/general/configure-keepassxc.sh; break;;
        2) echo -e "Not configuring KeePassXC"; break;;
    esac
done

echo -n -e ${C_RST}

echo -n -e ${C_MAGENTA}
echo "Preparation finished"
echo -n -e ${C_RST}
