#!/usr/bin/env bash

# Checking of ANSIBLE_VAULT_PASSWORD_FILE file exists
if [ -f /var/tmp/vlt_pf ]; then

    EDITOR=nano ansible-vault edit ~/.vault/vlt

else

    EDITOR=nano ansible-vault edit ~/.vault/vlt --ask-vault-password

fi

