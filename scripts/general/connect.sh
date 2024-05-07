#!/usr/bin/env bash

ansible-playbook /srv/inventories/start.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e role_only=true -e connection_connect=true -e single_role=nova.core.connection -l "$@"
# shellcheck disable=SC2046
ssh $(cat /tmp/ansible_connect)