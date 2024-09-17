#!/bin/bash

echo -n -e "${C_GREEN}"

# Generating node_modules folder
# Using /dev/null because the --silent flag is not working for some reason anymore
pushd /srv/ > /dev/null || exit
echo "y" | yarn install > /dev/null
popd > /dev/null || exit

# Generating known_hosts file
touch ~/.ssh/known_hosts

# Trusting github.com SSH host keys
if ! ssh-keygen -F github.com > /dev/null; then

    ssh-keyscan -H github.com >> ~/.ssh/known_hosts 2> /dev/null

fi

echo -n -e "${C_RST}"
