#!/usr/bin/env bash

unset ANSIBLE_VAULT_PASSWORD_FILE
ansible-vault rekey ~/.vault/vlt
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault/unlock-vault.sh