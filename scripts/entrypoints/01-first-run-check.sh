#!/bin/bash

echo -n -e "${C_GREEN}"

# Chcking if ansible folder exists, if not then including requirements installer
if [[ ! -d "/srv/ansible" ]]; then

  echo -e "Running first-run requirements installer..."
  # shellcheck disable=SC1091
  source scripts/general/install-all-requirements.sh CUSTOM

fi

# Checking if node_modules folder exists, if not then installing NPM packages
if [ -d /srv/node_modules ]; then

  cd /srv/ && yarn --silent

else

  echo -e "Installing NPM packages..."
  cd /srv/ && yarn

fi