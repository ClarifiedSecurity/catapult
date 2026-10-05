#!/usr/bin/env bash

echo -ne "${C_YELLOW}"

cp ~/.vault/vlt /tmp/vlt.yml
ansible-vault decrypt /tmp/vlt.yml

echo -e "Validating the existing vault syntax"

if [[ -z $(yamllint /tmp/vlt.yml -c ~/.vault/yamllint-config.yml) ]]; then

    echo -n

else

    while [[ -n $(yamllint /tmp/vlt.yml -c ~/.vault/yamllint-config.yml) ]]; do

        echo -e "The vault does not follow the YAML syntax rules."
        echo -e "https://yamllint.readthedocs.io/en/stable/rules.html"
        echo
        echo -e "The messages below show what needs fixing and on which lines."
        echo -e "Fix these issues before continuing."
        yamllint /tmp/vlt.yml -c ~/.vault/yamllint-config.yml
        read -rp "Press ENTER to open and edit the vault or press Ctrl + C to cancel"
        ${EDITOR} /tmp/vlt.yml

    done

fi

ansible-vault encrypt /tmp/vlt.yml --encrypt-vault-id default
cp /tmp/vlt.yml ~/.vault/vlt

echo -n -e "${C_RST}"