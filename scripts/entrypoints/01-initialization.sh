#!/bin/bash

echo -n -e "${C_GREEN}"

# Chcking if ansible folder exists, if not then including requirements installer
if [[ ! -d "/srv/ansible" ]]; then

  echo -e "Running first-run requirements installer..."
  # shellcheck disable=SC1091
  source scripts/general/install-all-requirements.sh CUSTOM

fi

# Installing or updating yarn npm packages
# Using /dev/null because the --silent flag is not working for some reason anymore
(cd /srv/ && yarn install > /dev/null)

# Checking if completions file exists, if not then creating it
if [[ ! -f "/home/builder/autocomplete.sh" ]]; then

  echo -e "Creating completions file..."
  /srv/scripts/general/autocomplete_generator.py

fi

echo -n -e "${C_RST}"
