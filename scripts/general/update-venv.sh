#!/usr/bin/env bash

# shellcheck disable=SC1091
source /srv/scripts/general/colors.sh

rm -rf "$HOME/.venv"
# shellcheck disable=SC2164
pushd "$HOME"; "$HOME/.cargo/bin/uv" venv; popd
source "$HOME/.venv/bin/activate"
"$HOME/.cargo/bin/uv" pip install -r /srv/defaults/requirements_src.txt
uv pip freeze > /srv/defaults/requirements.txt

echo -n -e "${C_YELLOW}"
echo -e "Versioned requirements written into /srv/defaults/requirements.txt"
echo -n -e "${C_RST}"