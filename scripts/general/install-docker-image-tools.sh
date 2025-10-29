#!/usr/bin/env bash

set -e # exit when any command fails

NODE_VERSION=v22.21.0

# Detecting platform architecture
if [[ "$(uname -m)" == "x86_64" ]]; then
  OS_PLATFORM=linux-x64
else
  OS_PLATFORM="linux-arm64"
fi

apt update
apt install -y curl xz-utils git git-lfs zsh # Required for Docker image creation
apt install -y ca-certificates rsync iputils-ping jq sshpass sudo unzip zip # Required for general Ansible usage
apt install -y vim iproute2 traceroute dnsutils netcat-openbsd nano procps p7zip-full neovim # Extra development & debugging tools
setcap cap_net_raw+ep /bin/ping # Allow non-root users to use ping

cd /tmp
curl -O https://nodejs.org/download/release/$NODE_VERSION/node-$NODE_VERSION-$OS_PLATFORM.tar.xz
mkdir -p /usr/local/lib/nodejs
tar -xJvf node-$NODE_VERSION-$OS_PLATFORM.tar.xz -C /usr/local/lib/nodejs

ln -s /usr/local/lib/nodejs/node-$NODE_VERSION-$OS_PLATFORM/bin/node /usr/bin/node
ln -s /usr/local/lib/nodejs/node-$NODE_VERSION-$OS_PLATFORM/bin/npm /usr/bin/npm
ln -s /usr/local/lib/nodejs/node-$NODE_VERSION-$OS_PLATFORM/bin/npx /usr/bin/npx
ln -s /usr/local/lib/nodejs/node-$NODE_VERSION-$OS_PLATFORM/bin/corepack /usr/bin/corepack

corepack enable

apt upgrade -y
apt autoremove -y
apt autoclean -y

# Cleanup to keep the layer size small
rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/*
rm -rf /tmp/*
rm -rf /home/builder/.cache/*