#!/bin/bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source /srv/scripts/general/colors.sh

export PATH=$HOME/.local/bin:$PATH
REQUIREMENTS_FILES="requirements*.yml" # Requirements file catch-all variable

# Activating the poetry environment for better speed
# shellcheck disable=SC1091
source "$(poetry env info -C /srv/poetry --path)/bin/activate"

echo -e "\033[32mGetting requirements from /srv/requirements folder...\033[0m"
cd /srv/requirements

# Installing all requirements based on requirements*.yml files and also installes all Python requirements based on poetry.lock
install_all_requirements () {

# Installing Python requirements based on poetry.lock
poetry install --directory=/srv/poetry --no-root

# Looping over all requirements.yml files in the folder and running install on them
for requirement_file in $REQUIREMENTS_FILES; do

  # Default requirements are installed in the ~/ansible folder under the project
  if [[ $requirement_file == requirements.yml ]]; then
    echo -e "\033[33mInstalling roles from $(readlink -f $requirement_file)\033[0m"
    ansible-galaxy role install -r $requirement_file --force --no-deps -p ~/ansible

    echo -e "\033[33mInstalling collections from $(readlink -f $requirement_file)\033[0m"
    ansible-galaxy collection install -r $requirement_file --force --no-deps -p ~/ansible
  else
    echo -e "\033[33mInstalling roles from $(readlink -f $requirement_file)\033[0m"
    ansible-galaxy role install -r $requirement_file --force --no-deps -p /srv/ansible

    echo -e "\033[33mInstalling collections from $(readlink -f $requirement_file)\033[0m"
    ansible-galaxy collection install -r $requirement_file --force --no-deps -p /srv/ansible
  fi
done
}

# Installing only requirements in requirements.yml file and Python requirements based on poetry.lock
install_notcustom_requirements () {

# Looping over all requirements.yml files in the folder and running install on them
for requirement_file in $REQUIREMENTS_FILES; do

  # Default requirements are installed in the ~/ansible folder under the project
  if [[ $requirement_file == requirements.yml ]]; then
    echo -e "\033[33mInstalling roles from $(readlink -f $requirement_file)\033[0m"
    ansible-galaxy role install -r $requirement_file --force --no-deps -p ~/ansible

    echo -e "\033[33mInstalling collections from $(readlink -f $requirement_file)\033[0m"
    ansible-galaxy collection install -r $requirement_file --force --no-deps -p ~/ansible
  fi
done
}

# Installing only requirements in requirements*.yml files and not the default requirements.yml file
install_custom_requirements () {

# Looping over all requirements.yml files in the folder and running install on them
for requirement_file in $REQUIREMENTS_FILES; do

  # Default requirements are installed in the ~/ansible folder under the project
  if [[ $requirement_file != requirements.yml ]]; then
    echo -e "\033[33mInstalling roles from $(readlink -f $requirement_file)\033[0m"
    ansible-galaxy role install -r $requirement_file --force --no-deps -p /srv/ansible

    echo -e "\033[33mInstalling collections from $(readlink -f $requirement_file)\033[0m"
    ansible-galaxy collection install -r $requirement_file --force --no-deps -p /srv/ansible
  fi
done
}

if [[ "$1" == 'ALL' ]]; then
  install_all_requirements
fi

if [[ "$1" == 'NOTCUSTOM' ]]; then
  install_notcustom_requirements
fi

if [[ "$1" == 'CUSTOM' ]]; then
  install_custom_requirements

  # Creating ansible to project root, to signify that the requirements have been installed.
  # Because when not using custom collections the ansible folder is not created.
  mkdir -p /srv/ansible

fi