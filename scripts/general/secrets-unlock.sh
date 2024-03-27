#!/usr/bin/env bash

if [[ "$USE_ANSIBLE_VAULT" == 0 ]]; then

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

  # Function to check for missing secret keys
  check_for_missing_keys () {

    # Checking if custom vault_example.yml exists and using it if it does
    if [[ -r custom/vault_example.yml ]]
    then

        VAULT_SRC=/srv/custom/vault_example.yml

      else

        VAULT_SRC=/srv/defaults/vault_example.yml

    fi

    # Validationg that all variables defined in the example are present in the vault
    SECRETS_SRC=$(cat $VAULT_SRC | yq -r 'keys[]')
    SECRETS_CURRENT_SRC=$1
    MISSING_KEYS=$(comm -23 <(echo -n "$SECRETS_SRC" | sort) <(echo -n "$SECRETS_CURRENT_SRC" | sort))

  }

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

  # Check if the vault has missing keys and add them
  SECRETS_CURRENT=$(ansible-vault view ~/.vault/vlt | yq -r 'keys[]' 2>/dev/null) # Sending errors to /dev/null because validation is done later
  check_for_missing_keys "$SECRETS_CURRENT"

  if [[ -z $MISSING_KEYS ]]; then

    echo -n

  else

    echo -e "${C_YELLOW}"
    cp ~/.vault/vlt /tmp/vlt.yml

    /srv/scripts/general/secrets-validate.sh

    echo -e "${C_YELLOW}"
    echo -e "Running the missing keys check again after syntax validation"

    SECRETS_CURRENT_FIXED=$(yq -r 'keys[]' < /tmp/vlt.yml)
    check_for_missing_keys "$SECRETS_CURRENT_FIXED"

    echo -e "${C_GREEN}"
    for key in $MISSING_KEYS; do

      echo -e "Adding missing key: $key:"
      echo -e "$key:" >> /tmp/vlt.yml

    done
    echo -e "${C_YELLOW}"

    ansible-vault encrypt /tmp/vlt.yml --encrypt-vault-id default

    echo -e "Copying the updated vault back to ~/.vault/vlt"
    cp /tmp/vlt.yml ~/.vault/vlt
    rm /tmp/vlt.yml
    echo -n -e "${C_RST}"

  fi

fi
