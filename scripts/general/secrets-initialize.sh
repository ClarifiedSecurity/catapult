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
      if [ "$VAULT_PASSWORD1" != "$VAULT_PASSWORD2" ]; then

          echo -n -e "${C_RED}"
          echo "Passwords do not match, try again"
          echo -n -e "${C_RST}"

      else

          echo "$VAULT_PASSWORD1" > /var/tmp/vlt_pf
          chmod 600 /var/tmp/vlt_pf
          break  # Exit the loop if passwords match

      fi

  done

  # Checking if custom start.yml if it exists
  if [ -f /srv/custom/vault_example.yml ]; then

      echo -e "Using custom vault_example.yml..."
      cp -R /srv/custom/vault_example.yml ~/.vault/vlt

    else

      cp -R /srv/defaults/vault_example.yml ~/.vault/vlt

  fi

  ansible-vault encrypt --vault-password-file /var/tmp/vlt_pf ~/.vault/vlt

  echo -e "${C_YELLOW}"
  echo -e "Catapult will now open the encrypted vault file for you to edit"
  echo -e "When you are done, use CTRL + X to save and exit"
  echo -e "You can edit your secrets at any time by running ctp-secrets-edit"
  read -rp $'\n'"Press Ctrl + C to cancel or Press enter to continue..."
  echo -e "${C_RST}"

  EDITOR=nano ansible-vault edit --vault-password-file /var/tmp/vlt_pf ~/.vault/vlt

}

# Checking if Ansible vault file exists and if not then creating a placeholder
if [[ ! -f ~/.vault/vlt ]]; then

  touch ~/.vault/vlt
  chmod 600 ~/.vault/vlt
  echo "ansible_vault_used: false" > ~/.vault/vlt

fi

# Preparing the Ansible vault if it's enabled
if [[ "$USE_ANSIBLE_VAULT" == 1 ]]; then

  if ! grep -q "ANSIBLE_VAULT;" ~/.vault/vlt; then

    encrypt_vault

  fi

fi