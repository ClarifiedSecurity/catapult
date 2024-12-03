#!/usr/bin/env bash

# shellcheck disable=SC1091
source /srv/scripts/general/colors.sh

rm -rf "$HOME/.venv"
pushd "$HOME" || exit ; "$HOME/.local/bin/uv" venv ; popd || exit
source "$HOME/.venv/bin/activate"
"$HOME/.local/bin/uv" pip install -r /srv/defaults/requirements_src.txt
$HOME/.local/bin/uv pip freeze > /srv/defaults/requirements.txt

echo -n -e "${C_YELLOW}"
echo -e "Versioned requirements written into /srv/defaults/requirements.txt"
echo -n -e "${C_RST}"