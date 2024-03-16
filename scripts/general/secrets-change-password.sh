#!/usr/bin/env bash

set -e

while true; do

    echo -n -e "${C_YELLOW}"
    echo
    read -r -s -p "Enter a new password that will be used to encrypt your secrets: " VAULT_PASSWORD1
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

        VAULT_PASSWORD=$(echo "$VAULT_PASSWORD1" | sha1sum | cut -d " " -f 1)
        echo "$VAULT_PASSWORD" > /var/tmp/vlt_pf_changed
        chmod 600 /var/tmp/vlt_pf_changed
        break  # Exit the loop if passwords match

    fi

done

ansible-vault rekey ~/.vault/vlt --new-vault-password-file /var/tmp/vlt_pf_changed
cp -R /var/tmp/vlt_pf_changed /var/tmp/vlt_pf
rm -f /var/tmp/vlt_pf_changed
chmod 600 /var/tmp/vlt_pf