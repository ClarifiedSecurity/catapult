#!/usr/bin/env bash

set -e # exit when any command fails

sudo apt update
sudo apt install -y gcc # Reqired for compiling some Python packages

# This sets the yarn version to stable (berry) and installs the packages
cd /srv
echo "y" | yarn set version stable
echo "y" | yarn install

# Python virtual environment
pushd "$HOME" || exit
curl -LsSf https://astral.sh/uv/install.sh | sh
# shellcheck disable=SC1091
source "$HOME/.cargo/env"
rm -rf "$HOME/.venv"
"$HOME/.cargo/bin/uv" venv
# shellcheck disable=SC1091
source "$HOME/.venv/bin/activate"
uv pip install -r /srv/defaults/requirements.txt
popd || exit

#########
# Shell #
#########

# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
zsh

# FZF
git clone https://github.com/junegunn/fzf.git "$HOME/.fzf" --depth 1
"$HOME/.fzf/install" --key-bindings --completion --update-rc

sudo apt remove -y gcc
sudo apt autoremove -y
sudo apt autoclean -y

# Cleanup to keep the layer size small
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf /var/cache/*
sudo rm -rf /tmp/*