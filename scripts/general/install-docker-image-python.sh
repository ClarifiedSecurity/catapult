#!/usr/bin/env bash

set -e # exit when any command fails
export BUILDER_HOME=/home/builder

sudo apt update
sudo apt install -y  # Reqired for Docker image creation
sudo apt install -y gcc # Reqired for compiling some Python packages

# This sets the yarn version to stable (berry)
(cd /srv && echo y | yarn set version stable )

# Python virtual environment
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.cargo/env
cd "$HOME"
rm -rf $HOME/.venv
$HOME/.cargo/bin/uv venv
source $HOME/.venv/bin/activate
uv pip install -r /srv/defaults/requirements.txt
cd /srv

# Shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
zsh
git clone https://github.com/denysdovhan/spaceship-prompt.git "$BUILDER_HOME/.oh-my-zsh/custom/themes/spaceship-prompt" --depth=1
ln -s "$BUILDER_HOME/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme" "$BUILDER_HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme"
git clone https://github.com/junegunn/fzf.git $BUILDER_HOME/.fzf --depth 1
$BUILDER_HOME/.fzf/install --key-bindings --completion --update-rc

# DEFAULT because extra requirements will be installed on first run and they can be updated with rebuilding the image
/srv/scripts/general/install-requirements.sh DEFAULT

sudo apt remove -y gcc
sudo apt autoremove -y
sudo apt autoclean -y

# Cleanup to keep the layer size small
sudo rm -rf /var/lib/apt/lists/*
sudo rm -rf /var/cache/*
sudo rm -rf /tmp/*