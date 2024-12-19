#!/usr/bin/env bash

# shellcheck disable=SC1091
/srv/scripts/general/secrets-initialize.sh

if [[ ! -f /var/tmp/vlt_pf ]]; then

  # Initialize a variable for the exit status of the ansible-vault command
  exit_status=1

  # Keep asking for the password until the correct one is entered
  while [[ $exit_status -ne 0 ]]; do

      echo -n -e "${C_YELLOW}"
      read -r -s -p "Please enter your encrypted secrets password: " VAULT_PASSWORD1
      VAULT_PASSWORD=$(echo "$VAULT_PASSWORD1" | sha1sum | cut -d " " -f 1)
      echo "$VAULT_PASSWORD" > /var/tmp/vlt_pf
      echo -e "${C_RST}"

      ansible-vault view ~/.vault/vlt > /dev/null 2>&1

      # Get the exit status of the ansible-vault command
      exit_status=$?

      # If the password is incorrect, print a message
      if [[ $exit_status -ne 0 ]]; then

          echo
          echo -e "You're almost there but your password seems to be incorrect, try again!"
          echo -e ICAgICAgICBfXyAgXwogICAgLi0uJyAgYDsgYC0uXyAgX18gIF8KICAgKF8sICAgICAgICAgLi06JyAgYDsgYC0uXwogLCdvIiggICAgICAgIChfLCAgICAgICAgICAgKQooX18sLScgICAgICAsJ28iKCAgICAgICAgICAgICk+CiAgICggICAgICAgKF9fLC0nICAgICAgICAgICAgKQogICAgYC0nLl8uLS0uXyggICAgICAgICAgICAgKQogICAgICAgfHx8ICB8fHxgLScuXy4tLS5fLi0nCiAgICAgICAgICAgICAgICAgIHx8fCAgfHx8ICA= | base64 -d
          echo

      fi

  done

else

  echo -n

fi
