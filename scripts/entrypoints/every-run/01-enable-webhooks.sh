#!/usr/bin/env bash

# Checking that WEBHOOK_URL is not empty
if [[ -n "$SLACK_WEBHOOK_URL" ]]; then

    SLACK_CALLBACK_PLUGIN="community.general.slack"

    # Combining existing callbacks_enabled from ansible.cfg with community.general.slack into ANSIBLE_CALLBACKS_ENABLED
    CFG_CALLBACKS=$(grep "callbacks_enabled" /srv/ansible.cfg | cut -d '=' -f 2 | tr -d ' ')
    ENV_CALLBACKS=$ANSIBLE_CALLBACKS_ENABLED

    # Constructing the final ANSIBLE_CALLBACKS variable based on ansible.cfg and existing environment variable
    ANSIBLE_CALLBACKS="$CFG_CALLBACKS,$SLACK_CALLBACK_PLUGIN,$ENV_CALLBACKS"

    # Cleaning up possible leading/trailing commas
    ANSIBLE_CALLBACKS="${ANSIBLE_CALLBACKS#,}"
    ANSIBLE_CALLBACKS="${ANSIBLE_CALLBACKS%,}"

    export ANSIBLE_CALLBACKS_ENABLED="${ANSIBLE_CALLBACKS}"

fi