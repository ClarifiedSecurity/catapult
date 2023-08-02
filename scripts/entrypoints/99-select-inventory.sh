#!/bin/bash

C_RED="\033[31m"
C_GREEN="\033[32m"
C_RST="\033[0m"

echo -e ${C_RST}
SEARCH_DIR=/srv/inventories
SEARCH_FOLDER=".git"
FOLDERS=($(find $SEARCH_DIR -type d -name $SEARCH_FOLDER -printf '%h\n' | sort))

#----------------------------------------End of variables, start of script----------------------------------------#

# Function to select inventory when using zsh
function zsh_selector() {
    if [ ${#FOLDERS[@]} -gt 0 ]; then

        for i in $(seq 1 ${#FOLDERS}); do

            folder_name=$(basename "${FOLDERS[i]}")
            echo -e "$i. ${C_GREEN}$folder_name${C_RST}"

        done

        echo -n "Select project: "
        read choice
        choice=$((choice))

        if [ ${choice-0} -ge 0 ] && [ ${choice-0} -lt $((${#FOLDERS} + 1)) ]; then

            selected_folder=${FOLDERS[choice]}
            selected_folder_name=$(basename "$selected_folder")
            echo -e "Your project's path is: ${C_GREEN}$selected_folder${C_RST}"
            cd $selected_folder

        else

            echo "Invalid selection."
            cd /srv

        fi
    else

        echo "No projects found."

    fi

}

# Function to select inventory when using bash
function bash_selector() {

    if [ ${#FOLDERS[@]} -gt 0 ]; then

        for i in "${!FOLDERS[@]}"; do

            folder_name=$(basename "${FOLDERS[i]}")
            echo -e "$((i+1)). ${C_GREEN}$folder_name${C_RST}"

        done

        read -p "Select project: " choice

        if [ ${choice-0} -ge 1 ] && [ ${choice-0} -le ${#FOLDERS[@]} ]; then

            selected_folder=${FOLDERS[choice-1]}
            selected_folder_name=$(basename "$selected_folder")
            echo -e "Your project's path is: ${C_GREEN}$selected_folder${C_RST}"
            cd $selected_folder

        else

            echo "Invalid selection."
            cd /srv

        fi
    else

        echo "No projects found."

    fi

}

if [[ -n ${ZSH_VERSION} ]] && [[ ! -z ${ZSH_VERSION} ]]; then

    zsh_selector

elif [[ -n $BASH_VERSION ]]; then

    bash_selector

else

  echo "Unknown shell"

fi
