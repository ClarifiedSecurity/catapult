#!/usr/bin/env bash

echo -n -e "${C_YELLOW}"

cp ~/.vault/vlt /tmp/vlt.yml
ansible-vault decrypt /tmp/vlt.yml

echo -e "Validating the existing vault syntax"

if [[ -z $(yamllint /tmp/vlt.yml -c ~/.vault/yamllint-config.yml) ]]; then

    echo -n

else

    while [[ -n $(yamllint /tmp/vlt.yml -c ~/.vault/yamllint-config.yml) ]]; do

        echo -e "Vault not matching to the YAML syntax rules - https://yamllint.readthedocs.io/en/stable/rules.html"
        echo -e "Please fix the following syntax errors in the vault:"
        yamllint /tmp/vlt.yml -c ~/.vault/yamllint-config.yml
        read -rp "Press ENTER to open and edit the vault or press Ctrl + C to cancel"
        nano /tmp/vlt.yml

    done

fi

ansible-vault encrypt /tmp/vlt.yml --encrypt-vault-id default
cp /tmp/vlt.yml ~/.vault/vlt

echo -n -e "${C_RST}"