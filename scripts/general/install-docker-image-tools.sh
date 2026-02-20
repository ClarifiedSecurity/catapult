#!/usr/bin/env bash

set -e # exit when any command fails

apt update
apt install -y curl xz-utils git git-lfs zsh locales # Required for Docker image creation
apt install -y ca-certificates rsync iputils-ping jq sshpass sudo unzip zip # Required for general Ansible usage
apt install -y vim iproute2 traceroute dnsutils netcat-openbsd nano procps p7zip-full neovim # Extra development & debugging tools
setcap cap_net_raw+ep /bin/ping # Allow non-root users to use ping
sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen # Uncomment the en_US.UTF-8 locale in the locale.gen file
locale-gen # Generate UTF-8 locale

apt upgrade -y
apt autoremove -y
apt autoclean -y

# Cleanup to keep the layer size small
rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/*
rm -rf /tmp/*
rm -rf /home/builder/.cache/*
