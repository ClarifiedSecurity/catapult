#!/usr/bin/env bash

echo -n -e "${C_GREEN}"

# Generating known_hosts file
touch ~/.ssh/known_hosts

# Trusting github.com SSH host keys
if ! ssh-keygen -F github.com > /dev/null; then

    ssh-keyscan -H github.com >> ~/.ssh/known_hosts 2> /dev/null

fi

echo -n -e "${C_RST}"
