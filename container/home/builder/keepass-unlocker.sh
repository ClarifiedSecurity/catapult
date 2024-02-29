#!/usr/bin/env bash

set -e

# Check if KeePass is already open
if [ -S /tmp/ansible-keepass.sock ]; then

  echo -e "KeePass already open"

# Unlocking KeePass
else

  until ~/keepass-decrypt-check.py; do

    # Checking if the KEEPASS_CI_PASSWORD is set
    # This can be used to unlock the KeePass database without user interaction for CI/CD
    if [ -z "$KEEPASS_CI_PASSWORD" ]; then

      read -rsp "$(echo -e "Enter your KeePass password: ")" kppwd && export KPPWD=$kppwd

    else

        export KPPWD=$KEEPASS_CI_PASSWORD

    fi

  done

  /home/builder/kpsock.py /home/builder/KPDB.kbdx --key /home/builder/KPDB.key --log kpsock.log --log-level WARNING --ttl 28800 &
  unset KPPWD
  sleep 0.25

fi