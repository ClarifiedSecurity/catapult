#!/usr/bin/env bash

set -e # exit when any command fails

apt update
apt install -y curl ca-certificates gnupg rsync iputils-ping jq sshpass git-lfs software-properties-common unzip
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

apt remove -y software-properties-common gnupg
apt autoremove -y
apt autoclean -y

# Cleanup to keep the image size down
rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/*
rm -rf /tmp/*
rm -rf /home/builder/.cache/*