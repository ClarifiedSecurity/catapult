#!/usr/bin/env bash

EDITOR=nano ansible-vault edit ~/.vault/vlt
/srv/scripts/general/secrets-validate.sh