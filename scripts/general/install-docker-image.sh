#!/usr/bin/env bash

set -e # exit when any command fails

apt update
apt install -y curl sudo git zsh gcc

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

apt install -y ca-certificates gnupg rsync iputils-ping jq sshpass git-lfs software-properties-common unzip
apt install -y iproute2 traceroute dnsutils netcat-openbsd vim # Development tools
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
apt update
apt install -y nodejs
corepack enable
cd /srv
yarn set version stable
apt upgrade -y

apt remove -y gcc software-properties-common gnupg
apt autoremove -y
apt autoclean -y
rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/*