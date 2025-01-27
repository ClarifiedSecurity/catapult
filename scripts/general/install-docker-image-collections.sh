#!/usr/bin/env bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source "$HOME/catapult-venv/.venv/bin/activate"

# Installing Ansible roles & collections
/srv/scripts/general/install-collections.sh

sudo apt autoremove -y
sudo apt autoclean -y

# Cleanup to keep the layer size small
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf /var/cache/*
sudo rm -rf /tmp/*