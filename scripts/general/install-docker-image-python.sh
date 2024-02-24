#!/usr/bin/env bash

set -e # exit when any command fails

apt update
apt install -y sudo git zsh # Reqired for Docker image creation
apt install -y gcc # Reqired for compiling some Python packages

su - builder -c '
set -e # exit when any command fails
export BUILDER_HOME=/home/builder

curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.cargo/env
cd $HOME
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

# NOTCUSTOM because custom requirements will be installed on first and they can be updated with rebuilding the image
/srv/scripts/general/install-all-requirements.sh NOTCUSTOM
'

{
	echo "source /home/builder/.default_aliases"
	echo "source /home/builder/.custom_aliases"
	echo "source /home/builder/.personal_aliases"
} >> /etc/zsh/zshrc

apt remove -y gcc
apt autoremove -y
apt autoclean -y

# Cleanup to keep the image size down
rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/*
rm -rf /tmp/*
rm -rf /home/builder/.cache/*