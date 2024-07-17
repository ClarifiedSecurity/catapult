#!/bin/bash

echo -n -e "${C_GREEN}"

# Installing or updating yarn npm packages
# Using /dev/null because the --silent flag is not working for some reason anymore
(cd /srv/ && echo "y" | yarn install > /dev/null)

# Checking if completions file exists, if not then creating it
if [[ ! -f "/home/builder/autocomplete.sh" ]]; then

  echo -n -e "${C_YELLOW}"
  echo -e "Generating completions..."
  /srv/scripts/general/autocomplete_generator.py
  echo -n -e "${C_RST}"

fi

echo -n -e "${C_RST}"
