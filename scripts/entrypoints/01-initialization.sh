#!/bin/bash

echo -n -e "${C_GREEN}"

# Generating node_modules folder
# Using /dev/null because the --silent flag is not working for some reason anymore
pushd /srv/ > /dev/null || exit
echo "y" | yarn install > /dev/null
popd > /dev/null || exit

echo -n -e "${C_RST}"
