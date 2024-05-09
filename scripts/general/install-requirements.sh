#!/bin/bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source /srv/scripts/general/colors.sh

export PATH=$HOME/.cargo/bin:$PATH
REQUIREMENTS_FILES="requirements*.yml" # Requirements file catch-all variable

# Activating the virtual environment
# shellcheck disable=SC1091
source "$HOME/.venv/bin/activate"

echo -n -e "${C_GREEN}"
echo -e Getting requirements from /srv/requirements folder...
echo -n -e "${C_RST}"

cd /srv/requirements

# Installing all requirements based on requirements*.yml files and also installes all Python requirements based on requirements.txt
install_all_requirements () {

# Installing Python requirements based on requirements.txt
uv pip install -r /srv/defaults/requirements.txt

# Looping over all requirements.yml files in the folder and running install on them
for REQUIREMENT_FILE in $REQUIREMENTS_FILES; do

  echo -n -e "${C_YELLOW}"

  # Default requirements are installed in the ~/ansible folder under the project
  if [[ $REQUIREMENT_FILE == requirements.yml ]]; then
    echo -e "Installing roles from $(readlink -f $REQUIREMENT_FILE)"
    ansible-galaxy role install -r "$REQUIREMENT_FILE" --force --no-deps -p ~/ansible

    echo -e "Installing collections from $(readlink -f $REQUIREMENT_FILE)"
    ansible-galaxy collection install -r "$REQUIREMENT_FILE" --force --no-deps -p ~/ansible --no-cache --clear-response-cache
  else
    echo -e "Installing roles from $(readlink -f $REQUIREMENT_FILE)"
    ansible-galaxy role install -r "$REQUIREMENT_FILE" --force --no-deps -p /srv/ansible

    echo -e "Installing collections from $(readlink -f $REQUIREMENT_FILE)"
    ansible-galaxy collection install -r "$REQUIREMENT_FILE" --force --no-deps -p /srv/ansible --no-cache --clear-response-cache
  fi

  echo -n -e "${C_RST}"

done
}

# Installing only requirements in requirements.yml file and Python requirements based on requirements.txt
install_default_requirements () {

# Looping over all requirements.yml files in the folder and running install on them
for REQUIREMENT_FILE in $REQUIREMENTS_FILES; do

  echo -n -e "${C_YELLOW}"

  # Default requirements are installed in the ~/ansible folder under the project
  if [[ $REQUIREMENT_FILE == requirements.yml ]]; then
    echo -e "Installing roles from $(readlink -f $REQUIREMENT_FILE)"
    ansible-galaxy role install -r "$REQUIREMENT_FILE" --force --no-deps -p ~/ansible

    echo -e "Installing collections from $(readlink -f $REQUIREMENT_FILE)"
    ansible-galaxy collection install -r "$REQUIREMENT_FILE" --force --no-deps -p ~/ansible --no-cache --clear-response-cache
  fi

  echo -n -e "${C_RST}"

done
}

# Installing only requirements in requirements*.yml files and not the default requirements.yml file
install_extra_requirements () {

# Looping over all requirements.yml files in the folder and running install on them
for REQUIREMENT_FILE in $REQUIREMENTS_FILES; do

  echo -n -e "${C_YELLOW}"

  # Default requirements are installed in the ~/ansible folder under the project
  if [[ $REQUIREMENT_FILE != requirements.yml ]]; then
    echo -e "Installing roles from $(readlink -f $REQUIREMENT_FILE)"
    ansible-galaxy role install -r "$REQUIREMENT_FILE" --force --no-deps -p /srv/ansible

    echo -e "Installing collections from $(readlink -f $REQUIREMENT_FILE)"
    ansible-galaxy collection install -r "$REQUIREMENT_FILE" --force --no-deps -p /srv/ansible --no-cache --clear-response-cache
  fi

  echo -n -e "${C_RST}"

done
}

if [[ "$1" == 'ALL' ]]; then
  install_all_requirements
fi

if [[ "$1" == 'DEFAULT' ]]; then
  install_default_requirements
fi

if [[ "$1" == 'EXTRA' ]]; then
  install_extra_requirements

  # Creating ansible to project root, to signify that the requirements have been installed.
  # Because when not using extra roles/collections the ansible folder is not created.
  mkdir -p /srv/ansible

fi

cd /srv

echo -n -e "${C_RST}"