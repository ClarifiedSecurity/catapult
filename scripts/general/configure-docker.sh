#!/usr/bin/env bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

###########################
# Docker restart function #
###########################
restart_docker() {

  # This function is required when updating Docker version and the service has too many restarts

  if [[ $(uname) == "Linux" ]]; then

      # shellcheck disable=SC2034
      for i in {1..10}; do

        if [[ $i == 1 ]]; then

          sudo systemctl stop docker --quiet

        fi

        if [[ $(systemctl is-active docker) == "active" ]]; then

            echo -e
            break

        else

          set +e
          echo -n -e "${C_YELLOW}"
          echo -e "Starting Docker $i..10..."
          systemctl reset-failed docker # This is required when updating from an older Docker version
          systemctl restart docker --quiet
          sleep 10
          echo -n -e "${C_RST}"
          set -e

        fi

      done

    if [[ $(systemctl is-active docker) != "active" ]]; then

      echo -n -e "${C_RED}"
      echo -e Error starting Docker service, restart your computer and run "${C_CYAN}./install.sh${C_RED}" again
      echo -e Check the docker.service logs if the issue remains.
      echo -n -e "${C_RST}"
      exit 1

    fi

  fi

}

###########################
# Docker install function #
###########################
install_docker(){

  echo -n -e "${C_RST}"

  if [[ $(uname) == "Linux" ]]; then

    DAEMON_PATH=/etc/docker/daemon.json

    if grep -q -E "ID=(kali|debian|ubuntu)" /etc/os-release; then

      if ! grep -q -r "download.docker.com" /etc/apt/sources.list.d/; then

        if grep -q "ID=ubuntu" /etc/os-release; then

          echo -n -e "${C_YELLOW}"
          echo "Adding Docker repo for $(lsb_release -cs)..."
          echo -n -e "${C_RST}"

          curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg --yes
          echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

        elif grep -q "ID=kali" /etc/os-release; then

          echo -n -e "${C_YELLOW}"
          echo "Adding Docker repo for $(lsb_release -cs)..."
          echo -n -e "${C_RST}"

          curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg --yes
          echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
          bullseye stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        elif grep -q "ID=debian" /etc/os-release; then

          echo -n -e "${C_YELLOW}"
          echo "Adding Docker repo for $(lsb_release -cs)..."
          echo -n -e "${C_RST}"

          curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg --yes
          echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        fi

      fi

    elif grep -q "arch" /etc/os-release; then

      echo -n -e "${C_YELLOW}"
      echo "Docker will be installed with pacman..."
      echo -n -e "${C_RST}"

    elif grep -q 'ID_LIKE="rhel centos fedora"' /etc/os-release; then

      echo -n -e "${C_YELLOW}"
      echo "Adding Docker repo for RedHat..."
      echo -n -e "${C_RST}"

      dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    else

      OS_VERSION=$(grep "^ID=" /etc/os-release | cut -d "=" -f2)
      echo -n -e "${C_RED}"
      echo -e "You are using unsupported or untested (Linux) operating system - ${C_CYAN}${OS_VERSION}${C_RED}. Catapult may still work if you install Docker manually"
      echo -e "You'll need to follow these steps:"
      echo -e
      echo -e "1) Install ${C_YELLOW}Docker engine and Docker compose plugin${C_RED} for your OS from: ${C_YELLOW}https://docs.docker.com/engine/install${C_RED}"
      echo -e "If you don't find your OS in the link above, read the documentation for your OS there might be guides available on how to install Docker"
      echo -e

      read -rp "Once you have installed Docker & Docker compose plugin Press ENTER key to continue..."
      echo -n -e "${C_RST}"

    fi

    # Installing Docker & required tools
    if grep -q -E "ID=(kali|debian|ubuntu)" /etc/os-release; then

      apt-get update
      apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin
      systemctl enable docker.service

    elif grep -q "arch" /etc/os-release; then

      pacman -S docker docker-compose docker-buildx --noconfirm
      mkdir -p /etc/docker
      systemctl enable docker.service

    elif grep -q 'ID_LIKE="rhel centos fedora"' /etc/os-release; then

      dnf makecache
      dnf install -y --allowerasing docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin
      systemctl enable docker.service

    fi

  fi

  if [[ $(uname) == "Darwin" ]]; then

    DAEMON_PATH=$HOME/.docker/daemon.json

    if [[ -x "$(command -v brew)" ]]; then

      brew install --cask docker

    else

        echo -n -e "${C_RED}"
        echo -e "Homebrew not installed, cannot install Docker"
        echo -n -e "${C_RST}"
        exit 1

    fi

    # Wait until Docker is running
    while ! docker ps >/dev/null 2>&1; do

        # Launch Docker
        echo "Waiting until Docker engine is running..."
        open --background --hide -a Docker --args --accept-license
        sleep 5

    done

  fi

####################################
# Docker daemon.json configuration #
####################################

DOCKER_CONFIG=$(cat <<EOF
{
  "experimental": true,
  "ip6tables": true
}
EOF
)

DOCKER_DAEMON_DIR=$(dirname "$DAEMON_PATH")

# Checking that the directory exists
if [[ -d $DOCKER_DAEMON_DIR ]]; then

    echo -e "${C_YELLOW}"
    echo -e "Updating ${C_CYAN}$DAEMON_PATH${C_YELLOW} with:"
    echo -e "$DOCKER_CONFIG" | jq
    echo -e

    # Checks that the file exists and is not empty
    if [[ ! -f $DAEMON_PATH ]] || [[ ! -s $DAEMON_PATH ]]; then

        echo "$DOCKER_CONFIG" | jq > "$DAEMON_PATH"
        restart_docker

    else

        CURRENT_FILE_HASH=$(sha1sum < "$DAEMON_PATH")
        jq '. + {"experimental": true, "ip6tables": true}' "$DAEMON_PATH" > /tmp/daemon.json
        mv /tmp/daemon.json "$DAEMON_PATH"
        UPDATED_FILE_HASH=$(sha1sum < "$DAEMON_PATH")

        if [[ $CURRENT_FILE_HASH != "$UPDATED_FILE_HASH" ]]; then

            restart_docker

        fi

    fi

else

    echo -n -e "${C_RED}"
    echo -e "The default Docker config folder does not exist, cannot update Docker daemon configuration"
    echo -e "Set the following configuration manually for Docker daemon for your OS:"
    echo -e "$DOCKER_CONFIG" | jq

    read -rp "Press ENTER key to continue..."
    echo -n -e "${C_RST}"

fi

}

echo -e "${C_GREEN}"
echo -e "Installing and configuring the latest Docker version?"
echo -e

# $1 == true comes from install.sh AUTOINSTALL parameter
if [[ $1 == true ]]; then

  install_docker

else

  options=(
    "Yes (recommended)."
    "No, I'll manage my Docker version and configuration myself (for advanced users)."
  )

  # shellcheck disable=SC2034
  select option in "${options[@]}"; do
      case "$REPLY" in
          yes|y|1) install_docker; break;;
          no|n|2) echo -e "Not installing and configuring Docker"; break;;
      esac
  done

fi

echo -n -e "${C_RST}"