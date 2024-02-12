#!/usr/bin/env bash

set -e

# Check if KeePass is already open
if [ -S /tmp/ansible-keepass.sock ]; then

  echo -e "KeePass already open"

# Unlocking KeePass
else

  until ~/keepass-decrypt-check.py; do

    read -rsp "$(echo -e "Enter your KeePass password: ")" kppwd && export KPPWD=$kppwd

  done

  /home/builder/kpsock.py /home/builder/KPDB.kbdx --key /home/builder/KPDB.key --log kpsock.log --log-level WARNING --ttl 28800 &
  unset KPPWD
  sleep 0.25

fi