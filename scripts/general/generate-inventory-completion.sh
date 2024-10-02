#!/usr/bin/env bash

echo -n -e "${C_RST}"

#set -x

function inventory_generator(){

    # For some reaseon some Ansible commands cannot detect the vault file from an environment variable
    ansible-inventory --playbook-dir /srv/inventories -e @/home/builder/.vault/vlt --graph | sed 's/[|@:]*//g' | sed 's/--//g' | sed 's/^[ \t]*//' | sort | uniq > "/tmp/$(basename "$(pwd)")_hosts"

}

if [[ -d "$(pwd)/group_vars" ]]; then

    echo -n -e "${C_YELLOW}"
    echo -e "Generating tab-completable inventory for ${C_CYAN}$(basename "$(pwd)")${C_YELLOW}..."
    echo -n -e "${C_RST}"

    # Generating tab-completable inventory file
    ( inventory_generator >/dev/null 2>&1 & disown >/dev/null 2>&1 )

    # Fetching the latest changes from the remote repository
    ( git fetch > /dev/null 2>&1 2>&1 & disown >/dev/null 2>&1 )

else

    echo -n -e "${C_RED}"
    echo -e "Cannot generate tab-completable inventory!"
    echo -e "No group_vars folder found in the current directory. Run ${C_CYAN}ctp project select${C_RED} to select a project first."
    echo -n -e "${C_RST}"

fi