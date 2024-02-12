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
        selected_folder_name=$(basename "$selected_folder")
        echo -e "Your project's path is: ${C_GREEN}$selected_folder${C_RST}"
        cd $selected_folder

    elif [ ${#FOLDERS[@]} -gt 0 ]; then

        for i in $(seq 1 ${#FOLDERS}); do

            folder_name=$(basename "${FOLDERS[i]}")
            echo -e "$i. ${C_GREEN}$folder_name${C_RST}"

        done

        echo -n "Select project: "
        read choice
        choice=$((choice))

        if (($choice >= 1 && choice <= ${#FOLDERS[@]})); then

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

    if [ ${#FOLDERS[@]} -eq 1 ]; then

        selected_folder=${FOLDERS[0]}
        selected_folder_name=$(basename "$selected_folder")
        echo -e "Your project's path is: ${C_GREEN}$selected_folder${C_RST}"
        cd $selected_folder

    elif [ ${#FOLDERS[@]} -gt 0 ]; then

        for i in "${!FOLDERS[@]}"; do

            folder_name=$(basename "${FOLDERS[i]}")
            echo -e "$((i+1)). ${C_GREEN}$folder_name${C_RST}"

        done

        echo -n "Select project: "
        read choice
        choice=$((choice))

        if (($choice >= 1 && choice <= ${#FOLDERS[@]})); then

            selected_folder=${FOLDERS[choice-1]}
            selected_folder_name=$(basename "$selected_folder")
            echo -e "Your project's path is: ${C_GREEN}$selected_folder${C_RST}"
            cd $selected_folder

        else

            echo "Invalid selection."
            cd /srv

        fi

    else

        echo "No projects found in /srv/inventories or project does not have .git folder."

    fi

}

if [ -z "${ZSH_VERSION}" ]; then

    bash_selector

elif [ -z "$BASH_VERSION" ]; then

    zsh_selector

else

  echo "Unknown shell"

fi
