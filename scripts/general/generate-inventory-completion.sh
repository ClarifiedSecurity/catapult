#!/usr/bin/env bash

echo -ne "${C_RST}"

function inventory_generator(){

    # Creating completion folder
    COMPLETION_DIR="/tmp/catapult_completion"
    mkdir -p "${COMPLETION_DIR}"

    # For some reason some Ansible commands cannot detect the vault file from an environment variable
    # The awk script walks the --graph tree (indentation = depth) and buffers each group until a host is found below it, so empty groups never get printed
    ansible-inventory --playbook-dir /srv/inventories -e @/home/builder/.vault/vlt --graph | awk '
        {
            match($0, /^[ |-]*/)
            name = substr($0, RLENGTH + 1)
            depth = gsub(/\|/, "", $0)
            if (substr(name, 1, 1) == "@") {
                sub(/^@/, "", name)
                sub(/:$/, "", name)
                pending[depth] = name
                printed[depth] = 0
            } else {
                for (d = 0; d < depth; d++) {
                    if (pending[d] != "" && !printed[d]) {
                        print pending[d]
                        printed[d] = 1
                    }
                }
                print name
            }
        }
    ' | sort | uniq > "${COMPLETION_DIR}/$(basename "$(pwd)")_hosts"

    ############################################################################################
    # Generating the tab-completable roles list based on local roles and installed collections #
    ############################################################################################

    # Finding all folders in the roles directory that contain main.yml and getting their relative path
    PROJECT_ROLES="$(find roles -name main.yml -exec dirname {} \; | sed 's/\/[^\/]*$//' | sort | uniq)"

    # Looking up all roles from installed collections and converting them to FQCN
    INSTALLED_COLLECTION_ROLES="$(find /srv/ansible/ansible_collections -name main.yml -exec dirname {} \; | sed 's/\/[^\/]*$//' | awk -F'/ansible_collections/' '{print $2}' | sed 's|/roles/|.|; s|/|.|g' | sort | uniq)"

    # Combining the two lists sorting items by name and saving to file
    echo -e "${PROJECT_ROLES}\n${INSTALLED_COLLECTION_ROLES}" | sed 's/^[ \t]*//' | sort | uniq > "${COMPLETION_DIR}/$(basename "$(pwd)")_roles"

}

if [[ -d "$(pwd)/group_vars" ]]; then
    echo -ne "${C_GREEN}"
    echo -e "Generating tab-completable inventory for ${C_CYAN}$(basename "$(pwd)")${C_GREEN} in the background..."
    echo -ne "${C_RST}"

    # Generating tab-completable inventory file
    ( inventory_generator >/dev/null 2>&1 & disown >/dev/null 2>&1 )

    # Fetching the latest changes from the remote repository
    ( GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no' git fetch > /dev/null 2>&1 & disown >/dev/null 2>&1 )
else
    echo -ne "${C_YELLOW}"
    echo -e "Cannot generate tab-completable inventory!"
    echo -e "No group_vars folder found in the current directory. Run ${C_CYAN}ctp project select${C_YELLOW} to select a project first."
    echo -ne "${C_RST}"
fi