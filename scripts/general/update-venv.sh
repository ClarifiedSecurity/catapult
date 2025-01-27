#!/usr/bin/env bash

# shellcheck disable=SC1091
source /srv/scripts/general/colors.sh

cp /srv/defaults/pyproject.toml "$HOME/catapult-venv/pyproject.toml"
uv sync --upgrade --project "$HOME/catapult-venv"
cp "$HOME/catapult-venv/uv.lock" /srv/defaults/uv.lock

echo -n -e "${C_YELLOW}"
echo -e "Versioned requirements written into /srv/defaults/uv.lock"
echo -n -e "${C_RST}"
