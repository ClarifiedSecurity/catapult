#!/bin/bash

set -e

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

echo -n -e "${C_CYAN}"

# Creating required files and folders to avoid errors
mkdir -p ./container/home/builder/.history
mkdir -p ./personal
mkdir -p ./personal/certificates
touch ./personal/.personal_aliases
touch ./personal/.makerc-personal

echo -n -e "${C_RST}"

# Checking for Docker version
MINIMUM_DOCKER_MAJOR_VERSION="26"
CURRENT_DOCKER_MAJOR_VERSION=$(docker --version | awk '{print $3}' | cut -d '.' -f 1)

if [[ "$CURRENT_DOCKER_MAJOR_VERSION" -lt "$MINIMUM_DOCKER_MAJOR_VERSION" ]]; then

    echo -n -e "${C_RED}"
    echo
    echo -e "Current Docker version $CURRENT_DOCKER_MAJOR_VERSION is too old!"
    echo -e "Your can run ${C_CYAN}make prepare${C_RED} to install the latest Docker version for your OS."
    echo
    echo -n -e "${C_RST}"
    exit 1

else

    echo -n

fi

# Checking if shell history file exists in legacy path and moving it to the new path
if [ -r ./container/home/builder/.zsh_history ]
then

  mv ./container/home/builder/.zsh_history ./container/home/builder/.history/.zsh_history

fi

# Checking if custom .makerc-vars.example exists and using it if it does
if [ -r custom/.makerc-vars.example  ]
then

    example_vars_file=custom/.makerc-vars.example

  else

    example_vars_file=.makerc-vars.example

fi

# Checking if all of the required variables are present in .makerc-vars
FILE_PATH=$example_vars_file

variables=()
parsing=false


while IFS= read -r line; do

  if [ "$parsing" = true ]; then

    if [[ "$line" == "# REQUIRED_END"* ]]; then

      parsing=false
    else

      line="${line#"${line%%[![:space:]]*}"}"
      line="${line%"${line##*[![:space:]]}"}"

      if [ -n "$line" ] && [[ ! "$line" =~ ^# ]]; then

        variable="${line%% *}"

        if [ -z "${!variable}" ]; then

          variables+=("$variable")

        fi
      fi
    fi
  else

    if [[ "$line" == "# REQUIRED_START"* ]]; then

      parsing=true
    fi
  fi
done < "$FILE_PATH"

for variable in "${variables[@]}"; do

  echo -n -e "${C_RED}"
  echo -e "$variable value missing in ${C_YELLOW}${ROOT_DIR}/.makerc-vars${C_RED}"
  echo -n -e "${C_RST}"

done

# Chcking if Ansible Vault is used
if [[ $MAKEVAR_USE_ANSIBLE_VAULT != 1 ]]; then

  echo -e "${C_YELLOW}"
  echo -e "Using KeePassXC will be deprecated at ${C_RED}01.07.2024${C_YELLOW} and Catapult will use Ansible Vault instead."
  echo -e "In order to configure Ansible Vault, you need to modify ${C_CYAN}MAKEVAR_USE_ANSIBLE_VAULT :=1${C_YELLOW} in your ${C_CYAN}.makerc-vars${C_YELLOW} file."
  echo -e "Then run ${C_CYAN}make start${C_YELLOW} and follow the instructions for setting up Ansible Vault."
  read -rp $'\n'"Press ENTER to to skip it for now or Ctrl + C to cancel and set the variable in your .makerc-vars file."
  echo -e "${C_RST}"

fi
