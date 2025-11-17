#!/usr/bin/env bash

set -e

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

# Creating required files and folders to avoid errors
mkdir -p ./container/home/builder/.history
mkdir -p ./personal/certificates
touch ./personal/.personal_aliases
touch "$HOME/.gitconfig"
