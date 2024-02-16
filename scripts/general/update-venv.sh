#!/usr/bin/env bash

rm -rf $HOME/.venv
pushd $HOME; $HOME/.cargo/bin/uv venv; popd
source $HOME/.venv/bin/activate
$HOME/.cargo/bin/uv pip install -r /srv/defaults/requirements_src.txt
uv pip freeze > /srv/defaults/requirements.txt
echo "Versioned requirements written into /srv/defaults/requirements.txt"