#!/bin/bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

scripts/general/configure-docker.sh

echo -n -e "${C_RST}"

echo -n -e "${C_MAGENTA}"
echo "Preparations finished successfully"
echo -n -e "${C_RST}"
