#!/bin/bash

set -e # exit when any command fails

scripts/general/configure-docker.sh

echo -e ${C_YELLOW}
echo -e "Do you want Catapult to install and configure KeePassXC database and key?"

options=(
  "Yes it's fine"
  "No, I already have my own database and key"
)

select option in "${options[@]}"; do
    case "$REPLY" in
        yes) scripts/general/configure-keepassxc.sh; break;;
        no) echo -e "Make sure you fill out the required values in ${ROOT_DIR}/.makerc-vars"; break;;
        y) scripts/general/configure-keepassxc.sh; break;;
        n) echo -e "Make sure you fill out the required values in ${ROOT_DIR}/.makerc-vars"; break;;
        1) scripts/general/configure-keepassxc.sh; break;;
        2) echo -e "Make sure you fill out the required values in ${ROOT_DIR}/.makerc-vars"; break;;
    esac
done

echo -n -e ${C_RST}

echo -n -e ${C_MAGENTA}
echo "Install finished successfully"
echo -n -e ${C_RST}
