#!/bin/bash

set -e # exit when any command fails

###########################
# Docker install function #
###########################
install_docker(){

  echo -n -e ${C_RST}

  if [[ $(uname) == "Linux" ]]; then

    if grep -q -E "ID=(kali|debian|ubuntu)" /etc/os-release; then

      if [[ -z $(grep -r download.docker.com /etc/apt/sources.list.d/) ]]; then

        if grep -q "ID=ubuntu" /etc/os-release; then

          echo -n -e ${C_MAGENTA}
          echo "Adding Docker repo for $(lsb_release -cs)..."
          echo -n -e ${C_RST}

          curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg --yes
          echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

        elif grep -q "ID=kali" /etc/os-release; then

          echo -n -e ${C_MAGENTA}
          echo "Adding Docker repo for $(lsb_release -cs)..."
          echo -n -e ${C_RST}

          curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg --yes
          echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
          bullseye stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        elif grep -q "ID=debian" /etc/os-release; then

          echo -n -e ${C_MAGENTA}
          echo "Adding Docker repo for $(lsb_release -cs)..."
          echo -n -e ${C_RST}

          curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg --yes
          echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        fi

      fi

    elif grep -q "arch" /etc/os-release; then

      echo -n -e ${C_MAGENTA}
      echo "Docker will be installed with pacman..."
      echo -n -e ${C_RST}

    else

      echo -n -e ${C_RED}
      echo -e "You are using unsupported or untested (Linux) operating system. Catapult may still work if you install Docker manually"
      echo -e "You'll need to follow these steps:"
      echo -e
      echo -e "1) Install ${C_YELLOW}Docker engine and Docker compose plugin${C_RED} for your OS from: ${C_YELLOW}https://docs.docker.com/engine/install${C_RED}"
      echo -e "1.1) If you don't find your OS in the link above look around in the internet there might be guides available on how to install Docker for your OS"
      echo -e

      read -p "Once you have installed Docker & Docker compose plugin press any key to continue..."
      echo -n -e ${C_RST}

    fi

    # Installing Docker & required tools
    if grep -q -E "ID=(kali|debian|ubuntu)" /etc/os-release; then

      apt-get update
      apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin

    elif grep -q "arch" /etc/os-release; then

      pacman -S docker docker-compose docker-buildx --noconfirm
      systemctl enable docker.service
      systemctl start docker.service
      mkdir -p /etc/docker

    fi

  fi

  if [[ $(uname) == "Darwin" ]]; then

    if [[ -x "$(command -v brew)" ]]; then

      brew install --cask docker

    else

        echo -n -e ${C_RED}
        echo -e "Homebrew not installed, cannot install Docker"
        echo -n -e ${C_RST}
        exit 1

    fi

    # Wait until Docker is running
    while ! docker ps >/dev/null 2>&1; do

        # Launch Docker
        echo "Waiting until Docker engine is running..."
        open --background --hide -a Docker
        sleep 5

    done

  fi

}

#######################################
# Docker daemon.json install function #
#######################################
update_docker_config(){

  if [[ -x "$(command -v docker)" ]]; then

    # Setting the correct daemon.json path
    if [[ $(uname) == "Darwin" ]]; then

      daemon_path=$HOME/.docker/daemon.json

    else

      daemon_path=/etc/docker/daemon.json

    fi

    if [[ $catapult_docker_mode == "unconfigured" ]]; then

      cp -R ${ROOT_DIR}/defaults/docker-compose-bridge.yml ${ROOT_DIR}/docker/docker-compose-network.yml

      echo -e ${C_YELLOW}
      echo -e "For IPv6 support make sure that the following parameters are in $daemon_path:"
      echo -e
      echo -e $docker_config | jq
      echo -e ${C_YELLOW}
      read -p "Press any key to continue"$'\n'

    else

      if [[ $(uname) == "Darwin" ]]; then

        echo -e
        echo -e "Overwriting your $daemon_path with the following config:"
        echo -e

      else

        echo -e
        echo -e "Overwriting your $daemon_path with the following config:"
        echo -e

      fi

      echo $docker_config | jq

      echo -e ${C_YELLOW}
      read -p "Press any key to continue, or Ctrl + C to cancel and start over..."$'\n'
      echo -e

      echo -n -e ${C_MAGENTA}
      echo "Updating Docker configuration..."
      echo -n -e ${C_RST}

      # Using the correct Docker Compose file for networking
      cp -R ${ROOT_DIR}/defaults/docker-compose-$catapult_docker_mode.yml ${ROOT_DIR}/docker/docker-compose-network.yml

      if [[ $(uname) == "Darwin" ]]; then

        DOCKER_CONFIG_FILE="$HOME/.docker/daemon.json"

      else

        DOCKER_CONFIG_FILE="/etc/docker/daemon.json"

      fi

      # Restarting Docker service if DOCKER_CONFIG_FILE does not exist or hash is different
      if [[ ! -f $DOCKER_CONFIG_FILE ]] || [[ $(echo $docker_config | jq | sha1sum - | cut -d " " -f 1) != $(cat $DOCKER_CONFIG_FILE | sha1sum - | cut -d " " -f 1) ]]; then

        echo $docker_config | jq > $DOCKER_CONFIG_FILE

        if [[ $(uname) == "Linux" ]]; then

            echo -n -e ${C_MAGENTA}
            echo "Restarting Docker service..."
            echo -n -e ${C_RST}

            systemctl restart docker

        fi

      fi

    fi

  else

    echo -n -e ${C_RED}
    echo "Cannot update configuration, docker not found."
    exit 1
    echo -n -e ${C_RST}

  fi

}

echo -e ${C_YELLOW}
echo -e "Installing latest Docker version for your OS"
echo -e

options=(
  "Yes it's fine"
  "No, I'll manage my Docker version manually"
)

select option in "${options[@]}"; do
    case "$REPLY" in
        yes) install_docker; break;;
        no) echo -e "Not installing Docker"; break;;
        y) install_docker; break;;
        n) echo -e "Not installing Docker"; break;;
        1) install_docker; break;;
        2) echo -e "Not installing Docker"; break;;
    esac
done

echo -n -e ${C_RST}

docker_config_bridge=$(cat <<EOF
{
  "experimental": true,
  "ip6tables": true
}
EOF
)

docker_config_host=$(cat <<EOF
{
  "iptables": false,
  "ip6tables": false
}
EOF
)

echo -e ${C_YELLOW}
echo -e "Do you want Docker to automatically configure IPv6 & manage it's IPtables?"
echo -e

options=(
  "Yes it's fine (recommended - will use Docker bridge network)"
  "No I'll manage IPTables myself (advanced - will use Docker host network)"
  "No it might break my existing configurations, I'll manually add the required parameters (advanced - will use Docker bridge network)"
)

select option in "${options[@]}"; do
    case "$REPLY" in
        1) catapult_docker_mode=bridge docker_config=$docker_config_bridge update_docker_config; break;;
        2) catapult_docker_mode=host docker_config=$docker_config_host update_docker_config; break;;
        3) catapult_docker_mode=unconfigured docker_config=$docker_config_bridge update_docker_config; break;;
    esac
done

# Configuring Docker network if docker is installed
if [[ -x "$(command -v docker)" ]]; then

  echo -n -e ${C_MAGENTA}
  echo "Checking if ${CONTAINER_NETWORK} exists..."
  echo -n -e ${C_RST}

  if [[ -z $(docker network ls | grep ${CONTAINER_NETWORK}) ]]; then

    echo -n -e ${C_MAGENTA}
    echo "Creating Docker ${CONTAINER_NETWORK} network..."
    echo -n -e ${C_RST}

    docker network create ${CONTAINER_NETWORK} --ipv6 --subnet ${CONTAINER_NETWORK_IPV6_SUBNET} --subnet ${CONTAINER_NETWORK_IPV4_SUBNET}

  fi

else

  echo -n -e ${C_RED}
  echo "Cannot create ${CONTAINER_NETWORK} network, docker not found."
  exit 1
  echo -n -e ${C_RST}

fi

echo -n -e ${C_RST}