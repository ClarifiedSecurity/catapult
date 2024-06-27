#!/bin/bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source /srv/scripts/general/colors.sh

echo -n -e "${C_YELLOW}"

# Installing Ansible roles & collections
ansible-galaxy role install -r /srv/defaults/requirements.yml --force --no-deps -p ~/ansible
ansible-galaxy collection install -r /srv/defaults/requirements.yml --force --no-deps -p ~/ansible --no-cache --clear-response-cache

echo -n -e "${C_RST}"