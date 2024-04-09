#!/bin/bash

echo -e "${C_RST}"
SEARCH_DIR=/srv/inventories
SEARCH_FOLDER=".git"
FOLDERS=($(find $SEARCH_DIR -name $SEARCH_FOLDER -printf '%h\n' | sort))

#----------------------------------------End of variables, start of script----------------------------------------#

# Function to select inventory when using zsh
function zsh_selector() {
    if [ ${#FOLDERS[@]} -eq 1 ]; then

        selected_folder=${FOLDERS[1]}
        echo -e "Your project's path is: ${C_GREEN}$selected_folder${C_RST}"
        cd "$selected_folder" || exit

    elif [ ${#FOLDERS[@]} -gt 0 ]; then

        for i in $(seq 1 ${#FOLDERS}); do

            folder_name=$(basename "${FOLDERS[i]}")
            echo -e "$i. ${C_GREEN}$folder_name${C_RST}"

        done

        echo -n "Select project: "
        read -r choice
        choice=$((choice))

        if (($choice >= 1 && choice <= ${#FOLDERS[@]})); then

            selected_folder=${FOLDERS[choice]}
            echo -e "Your project's path is: ${C_GREEN}$selected_folder${C_RST}"
            # shellcheck disable=SC2164
            cd "$selected_folder"
            touch "/tmp/$(basename "$selected_folder")_hosts" # This is to avoid completion erros if the inventory_generator function fails

        else

            echo "Invalid selection."
            cd /srv || exit

        fi

    else

        echo "No projects found."

    fi

}

# Function to select inventory when using bash
function bash_selector() {

    if [ ${#FOLDERS[@]} -eq 1 ]; then

        selected_folder=${FOLDERS[0]}
        echo -e "Your project's path is: ${C_GREEN}$selected_folder${C_RST}"
        cd "$selected_folder" || exit

    elif [ ${#FOLDERS[@]} -gt 0 ]; then

        for i in "${!FOLDERS[@]}"; do

            folder_name=$(basename "${FOLDERS[i]}")
            echo -e "$((i+1)). ${C_GREEN}$folder_name${C_RST}"

        done

        echo -n "Select project: "
        read -r choice
        choice=$((choice))

        if (($choice >= 1 && choice <= ${#FOLDERS[@]})); then

            selected_folder=${FOLDERS[choice-1]}
            echo -e "Your project's path is: ${C_GREEN}$selected_folder${C_RST}"
            # shellcheck disable=SC2164
            cd "$selected_folder"
            touch "/tmp/$(basename "$selected_folder")_hosts" # This is to avoid completion erros if the inventory_generator function fails

        else

            echo "Invalid selection."
            cd /srv || exit

        fi

    else

        echo "No projects found in /srv/inventories or project does not have .git folder."

    fi

}

function inventory_generator(){

    # Checking if USE_ANSIBLE_VAULT is set to 1
    # For some reaseon some Ansible commands cannot detect the vault file from an environment variable
    if [[ "$USE_ANSIBLE_VAULT" == 1 ]]; then

        ansible-inventory --playbook-dir /srv/inventories -e @/home/builder/.vault/vlt --graph | sed 's/[|@:]*//g' | sed 's/--//g' | sed 's/^[ \t]*//' | sort | uniq > "/tmp/$(basename "$selected_folder")_hosts"

    else

        ansible-inventory --playbook-dir /srv/inventories --graph | sed 's/[|@:]*//g' | sed 's/--//g' | sed 's/^[ \t]*//' | sort | uniq > "/tmp/$(basename "$selected_folder")_hosts"

    fi

}

if [ -z "${ZSH_VERSION}" ]; then

    bash_selector
    ( inventory_generator >/dev/null 2>&1 & disown >/dev/null 2>&1 )

elif [ -z "$BASH_VERSION" ]; then

    zsh_selector
    ( inventory_generator >/dev/null 2>&1 & disown >/dev/null 2>&1 )

else

  echo "Unknown shell"

fi
