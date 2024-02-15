#!/usr/bin/env bash

set -e # exit when any command fails

apt update
apt upgrade -y
apt install -y sudo ca-certificates curl gnupg gcc rsync iputils-ping jq sshpass git git-lfs zsh software-properties-common unzip
apt install -y iproute2 traceroute dnsutils netcat-openbsd vim # Development tools
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
apt update
apt install -y nodejs
corepack enable
cd /srv
yarn set version stable

su - builder -c '
export BUILDER_HOME=/home/builder

# Poetry
curl -sSL https://install.python-poetry.org | python3 -
$BUILDER_HOME/.local/bin/poetry config installer.max-workers 10
$BUILDER_HOME/.local/bin/poetry install --directory=/srv/poetry --no-root
for CACHE in $($BUILDER_HOME/.local/bin/poetry cache list); do $BUILDER_HOME/.local/bin/poetry cache clear $CACHE --all -q; done

# Shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
zsh
git clone https://github.com/denysdovhan/spaceship-prompt.git "$BUILDER_HOME/.oh-my-zsh/custom/themes/spaceship-prompt" --depth=1
ln -s "$BUILDER_HOME/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme" "$BUILDER_HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme"
mkdir $BUILDER_HOME/.oh-my-zsh/custom/plugins/poetry
$BUILDER_HOME/.local/bin/poetry completions zsh > $BUILDER_HOME/.oh-my-zsh/custom/plugins/poetry/_poetry
git clone https://github.com/junegunn/fzf.git $BUILDER_HOME/.fzf --depth 1
$BUILDER_HOME/.fzf/install --key-bindings --completion --update-rc
echo "source $BUILDER_HOME/.default_aliases" | sudo tee -a /etc/zsh/zshrc
echo "source $BUILDER_HOME/.custom_aliases" | sudo tee -a /etc/zsh/zshrc
echo "source $BUILDER_HOME/.personal_aliases" | sudo tee -a /etc/zsh/zshrc

# NOTCUSTOM because custom requirements will be installed on first and they can be updated with rebuilding the image
/srv/scripts/general/install-all-requirements.sh NOTCUSTOM
'

apt remove -y gcc software-properties-common gnupg
apt autoremove -y
apt autoclean -y
rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/*