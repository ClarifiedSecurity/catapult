#!/usr/bin/env bash

echo -n -e "${C_RST}"

function inventory_generator(){

    # For some reason some Ansible commands cannot detect the vault file from an environment variable
    ansible-inventory --playbook-dir /srv/inventories -e @/home/builder/.vault/vlt --graph | sed 's/[|@:]*//g' | sed 's/--//g' | sed 's/^[ \t]*//' | sort | uniq > "/tmp/$(basename "$(pwd)")_hosts"

    ############################################################################################
    # Generating the tab-completable roles list based on local roles and installed collections #
    ############################################################################################

    # Finding all folders in the roles directory that contain main.yml and getting their relative path
    PROJECT_ROLES="$(find roles -name main.yml -exec dirname {} \; | sed 's/\/[^\/]*$//' | sort | uniq)"

    # Looking up all roles from installed collections and converting them to FQCN
    INSTALLED_COLLECTION_ROLES="$(find /srv/ansible/ansible_collections -name main.yml -exec dirname {} \; | sed 's/\/[^\/]*$//' | awk -F'/ansible_collections/' '{print $2}' | sed 's|/roles/|.|; s|/|.|g' | sort | uniq)"

    # Combining the two lists sorting items by name and saving to file
    echo -e "${PROJECT_ROLES}\n${INSTALLED_COLLECTION_ROLES}" | sed 's/^[ \t]*//' | sort | uniq > "/tmp/$(basename "$(pwd)")_roles"

}

if [[ -d "$(pwd)/group_vars" ]]; then

    echo -n -e "${C_YELLOW}"
    echo -e "Generating tab-completable inventory for ${C_CYAN}$(basename "$(pwd)")${C_YELLOW} in the background..."
    echo -n -e "${C_RST}"

    # Generating tab-completable inventory file
    ( inventory_generator >/dev/null 2>&1 & disown >/dev/null 2>&1 )

    # Fetching the latest changes from the remote repository
    ( GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no' git fetch > /dev/null 2>&1 2>&1 & disown >/dev/null 2>&1 )

else

    echo -n -e "${C_YELLOW}"
    echo -e "Cannot generate tab-completable inventory!"
    echo -e "No group_vars folder found in the current directory. Run ${C_CYAN}ctp project select${C_YELLOW} to select a project first."
    echo -n -e "${C_RST}"

fi