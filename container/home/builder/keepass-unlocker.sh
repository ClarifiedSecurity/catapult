#!/usr/bin/env bash

# Check if KeePass is already open
if ls '/tmp' | grep -i ansible-keepass.sock -q; then

  echo -n -e ${C_GREEN}
  echo -e "KeePass already open"

# Unlocking KeePass
else

  until ~/keepass-decrypt-check.py; do

    read -s -p "$(echo -e "Enter your KeePass password: ")" kppwd && export KPPWD=$kppwd

  done

  /home/builder/kpsock.py /home/builder/KPDB.kbdx --key /home/builder/KPDB.key --log kpsock.log --log-level WARNING --ttl 28800 &
  unset KPPWD
  sleep 1

fi