#! /bin/bash

# Checking that WEBHOOK_URL is not empty
if [[ "$MAKEVAR_ARA_ENABLE" == 1 ]]; then

    # This is a bit strange since defining ANSIBLE_CALLBACK_PLUGINS alone is not enough to turn on ARA callbacks
    # Compared to webhooks where ANSIBLE_CALLBACKS needs to be defined to turn on the callback

    ARA_CALLBACK_PLUGIN_PATH="$(python3 -m ara.setup.callback_plugins)"

    # Getting existing ANSIBLE_CALLBACK_PLUGINS and callback_plugins from ansible.cfg
    CFG_CALLBACK_PLUGIN_PATHS=$(grep "callback_plugins" /srv/ansible.cfg | cut -d '=' -f 2 | tr -d ' ')
    ENV_CALLBACK_PLUGIN_PATHS=$ANSIBLE_CALLBACK_PLUGINS

    # Constructing the final ANSIBLE_CALLBACK_PLUGINS variable based on ansible.cfg and existing environment variable
    ANSIBLE_CALLBACK_PLUGINS="$CFG_CALLBACK_PLUGIN_PATHS,$ARA_CALLBACK_PLUGIN_PATH,$ENV_CALLBACK_PLUGIN_PATHS"

    # Cleaning up possible leading/trailing commas
    ANSIBLE_CALLBACK_PLUGINS="${ANSIBLE_CALLBACK_PLUGINS#,}"
    ANSIBLE_CALLBACK_PLUGINS="${ANSIBLE_CALLBACK_PLUGINS%,}"

    export ANSIBLE_CALLBACK_PLUGINS="${ANSIBLE_CALLBACK_PLUGINS}"

    # ara-manage migrate

fi