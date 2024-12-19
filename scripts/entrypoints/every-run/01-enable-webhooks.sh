#!/bin/bash

# Checking that WEBHOOK_URL is not empty
if [ -n "$SLACK_WEBHOOK_URL" ]; then

    # Checking if callbacks_enabled is used in ansible.cfg
    if grep -q "callbacks_enabled" /srv/ansible.cfg; then

        # Combining existing callbacks_enabled with community.general.slack into ANSIBLE_CALLBACKS_ENABLED
        CFG_CALLBACKS=$(grep "callbacks_enabled" /srv/ansible.cfg | cut -d '=' -f 2 | tr -d ' ')

        unset ANSIBLE_CALLBACKS_ENABLED
        export ANSIBLE_CALLBACKS_ENABLED="$CFG_CALLBACKS,community.general.slack"

    # Checking if ANSIBLE_CALLBACKS_ENABLED env var exists
    elif [ -n "$ANSIBLE_CALLBACKS_ENABLED" ]; then

        # Checking if existing ANSIBLE_CALLBACKS_ENABLED has already been saved to EXISTING_ANSIBLE_CALLBACKS_ENABLED
        if [ -z "$EXISTING_ANSIBLE_CALLBACKS_ENABLED" ]; then

            # Saving existing ANSIBLE_CALLBACKS_ENABLED to avoid mangling it on multiple runs
            export EXISTING_ANSIBLE_CALLBACKS_ENABLED="$ANSIBLE_CALLBACKS_ENABLED"

        fi

        # Adding community.general.slack to ANSIBLE_CALLBACKS_ENABLED
        export ANSIBLE_CALLBACKS_ENABLED="$EXISTING_ANSIBLE_CALLBACKS_ENABLED,community.general.slack"

    else

        # Adding community.general.slack to ANSIBLE_CALLBACKS_ENABLED
        export ANSIBLE_CALLBACKS_ENABLED="community.general.slack"

    fi

else

    echo -n

fi
