#!/usr/bin/env bash

if [[ "$USE_ANSIBLE_VAULT" == 0 ]] || [[ -z "$USE_ANSIBLE_VAULT" ]]; then

  # Check if KeePass is already open
  if [[ -S /tmp/ansible-keepass.sock ]]; then

    echo -e "KeePass already open"

  # Unlocking KeePass
  else

    until ~/keepass-decrypt-check.py; do

      # Checking if the KEEPASS_CI_PASSWORD is set
      # This can be used to unlock the KeePass database without user interaction for CI/CD
      if [[ -z "$KEEPASS_CI_PASSWORD" ]]; then

        read -rsp "$(echo -e "Enter your KeePass password: ")" kppwd && export KPPWD=$kppwd

      else

          export KPPWD=$KEEPASS_CI_PASSWORD

      fi

    done

    /home/builder/kpsock.py /home/builder/KPDB.kbdx --key /home/builder/KPDB.key --log kpsock.log --log-level WARNING --ttl 28800 &
    unset KPPWD
    sleep 0.25

  fi

elif [[ "$USE_ANSIBLE_VAULT" == 1 ]]; then

  # shellcheck disable=SC1091
  source /srv/scripts/general/secrets-initialize.sh

  export CATAPULT_VAULT_PATH="-e @~/.vault/vlt"
  export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault/unlock-vault.sh
  unset KEEPASS_DEPLOYER_CREDENTIALS_PATH

  if [ ! -f /var/tmp/vlt_pf ]; then

    # Initialize a variable for the exit status of the ansible-vault command
    exit_status=1

    # Keep asking for the password until the correct one is entered
    while [ $exit_status -ne 0 ]; do

        echo -n -e "${C_YELLOW}"
        read -r -s -p "Please enter your encrypted secrets password: " VAULT_PASSWORD1
        VAULT_PASSWORD=$(echo "$VAULT_PASSWORD1" | sha1sum | cut -d " " -f 1)
        echo "$VAULT_PASSWORD" > /var/tmp/vlt_pf
        echo -e "${C_RST}"

        ansible-vault view ~/.vault/vlt > /dev/null 2>&1

        # Get the exit status of the ansible-vault command
        exit_status=$?

        # If the password is incorrect, print a message
        if [ $exit_status -ne 0 ]; then

            echo
            echo -e "You're almost there but your KeePass password seems to be incorrect, try again!"
            echo -e ICAgICAgICBfXyAgXwogICAgLi0uJyAgYDsgYC0uXyAgX18gIF8KICAgKF8sICAgICAgICAgLi06JyAgYDsgYC0uXwogLCdvIiggICAgICAgIChfLCAgICAgICAgICAgKQooX18sLScgICAgICAsJ28iKCAgICAgICAgICAgICk+CiAgICggICAgICAgKF9fLC0nICAgICAgICAgICAgKQogICAgYC0nLl8uLS0uXyggICAgICAgICAgICAgKQogICAgICAgfHx8ICB8fHxgLScuXy4tLS5fLi0nCiAgICAgICAgICAgICAgICAgIHx8fCAgfHx8ICA= | base64 -d
            echo

        fi

    done

  else

    echo -n

  fi

fi
