#!/usr/bin/env bash

set -e # exit when any command fails

apt update
apt install -y curl xz-utils git git-lfs zsh # Required for Docker image creation
apt install -y ca-certificates rsync iputils-ping jq sshpass sudo unzip zip # Required for general Ansible usage
apt install -y vim iproute2 traceroute dnsutils netcat-openbsd nano procps p7zip-full neovim # Extra development & debugging tools
setcap cap_net_raw+ep /bin/ping # Allow non-root users to use ping

apt upgrade -y
apt autoremove -y
apt autoclean -y

# Cleanup to keep the layer size small
rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/*
rm -rf /tmp/*
rm -rf /home/builder/.cache/*
