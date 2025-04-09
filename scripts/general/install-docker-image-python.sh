#!/usr/bin/env bash

set -e # exit when any command fails

sudo apt update
sudo apt install -y gcc # Required for compiling some Python packages

# This sets the yarn version to stable (berry) and installs the packages
cd /srv
echo "y" | yarn set version stable
echo "y" | yarn install

##############################
# Python virtual environment #
##############################

curl -LsSf https://astral.sh/uv/install.sh | sh
# shellcheck disable=SC1091
source "$HOME/.local/bin/env"

# shellcheck disable=SC1091
pushd "$HOME/catapult-venv" || exit
uv sync
# shellcheck disable=SC1091
source "$HOME/catapult-venv/.venv/bin/activate"
rm pyproject.toml
rm uv.lock
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

sudo apt purge -y gcc
sudo apt autoremove -y
sudo apt autoclean -y

# Cleanup to keep the layer size small
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf /var/cache/*
sudo rm -rf /tmp/*
rm "$HOME/.bashrc"
rm "$HOME/.zshrc"