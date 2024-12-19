#!/usr/bin/env bash

# Ansible vault first-run configuration function
encrypt_vault () {

  while true; do

      echo -n -e "${C_YELLOW}"
      echo
      read -r -s -p "Enter a password that will be used to encrypt your secrets: " VAULT_PASSWORD1
      echo

      read -r -s -p "Repeat password: " VAULT_PASSWORD2
      echo
      echo -n -e "${C_RST}"

      # Check if the passwords match
      if [[ "$VAULT_PASSWORD1" != "$VAULT_PASSWORD2" ]]; then

          echo -n -e "${C_RED}"
          echo "Passwords do not match, try again"
          echo -n -e "${C_RST}"

      else

          VAULT_PASSWORD=$(echo "$VAULT_PASSWORD1" | sha1sum | cut -d " " -f 1)
          echo "$VAULT_PASSWORD" > /var/tmp/vlt_pf
          chmod 600 /var/tmp/vlt_pf
          break  # Exit the loop if passwords match

      fi

  done

  # Checking if custom start.yml if it exists
  if [[ -f /srv/custom/vault_example.yml ]]; then

      VAULT_EXAMPLE_FILE=custom/vault_example.yml
      cp -R /srv/$VAULT_EXAMPLE_FILE ~/.vault/vlt

    else

      VAULT_EXAMPLE_FILE=defaults/vault_example.yml
      cp -R /srv/$VAULT_EXAMPLE_FILE ~/.vault/vlt

  fi

  ansible-vault encrypt ~/.vault/vlt --encrypt-vault-id default

  echo -e "${C_YELLOW}"
  echo -e "Catapult will now open the encrypted vault file for you to edit"
  echo -e "When you are done, use CTRL + X to exit and save"
  echo -e "You can edit your secrets later by running ${C_CYAN}ctp secrets edit${C_YELLOW}"
  echo -e "You can restart this process by deleting your vault from container/home/builder/.vault/vlt"
  read -rp $'\n'"Press ENTER to continue or Ctrl + C to cancel"
  echo -e "${C_RST}"

  /srv/scripts/general/secrets-edit.sh

}

# Checking if Ansible vault file exists and if not then creating a placeholder
if [[ ! -f ~/.vault/vlt ]]; then

  touch ~/.vault/vlt
  chmod 600 ~/.vault/vlt

fi

# Preparing the Ansible vault
if ! grep -q "ANSIBLE_VAULT;" ~/.vault/vlt ; then

  encrypt_vault

fi