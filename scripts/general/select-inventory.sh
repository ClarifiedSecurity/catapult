#!/usr/bin/env bash

# shellcheck disable=SC1091
source /srv/scripts/general/colors.sh

SEARCH_DIR="/srv/inventories"
SEARCH_FOLDER=".git"
# shellcheck disable=SC2207
FOLDERS=($(find -L "$SEARCH_DIR" \( -type d -o -type l -o -type f \) -name "$SEARCH_FOLDER" -exec dirname {} \; | sort))

#--------------------End of variables, start of script--------------------#

# This project checks if the current project has a scripts/catapult-project-customizer.sh file.
# If present then sources it with load parameter on entering the project and with unload parameter on exiting the project.
function project_customization_loader() {

    if [ -f "$(pwd)/scripts/catapult-project-customizer.sh" ]; then

        echo -n -e "${C_GREEN}"
        echo -e "Unloading $(basename "$(pwd)") project customizer..."
        echo -n -e "${C_RST}"
        # shellcheck disable=SC1091
        source "$(pwd)/scripts/catapult-project-customizer.sh" unload

    fi

    if [ -f "$selected_folder/scripts/catapult-project-customizer.sh" ]; then

        echo -n -e "${C_GREEN}"
        echo -e "Loading $(basename "$selected_folder") project customizer..."
        echo -n -e "${C_RST}"

        # shellcheck disable=SC1091
        source "$selected_folder/scripts/catapult-project-customizer.sh" load

    fi

}

# Function to select inventory
function inventory_selector() {
    if [ ${#FOLDERS[@]} -eq 1 ]; then

        selected_folder=${FOLDERS[1]}
        echo -e "Your project's path is: ${C_GREEN}$selected_folder${C_RST}"
        project_customization_loader
        # https://github.com/spaceship-prompt/spaceship-prompt/issues/1193
        cd "$selected_folder" > /dev/null 2>/dev/null || exit

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
            project_customization_loader
            # shellcheck disable=SC2164
            cd "$selected_folder"
            touch "/tmp/$(basename "$selected_folder")_hosts" # This is to avoid completion erros if the inventory_generator function fails

        else

            echo -n -e "${C_RED}"
            echo "Invalid project selection."
            echo -n -e "${C_RST}"
            cd /srv || exit

        fi

    else

        echo "No projects found in /srv/inventories or project does not have .git folder."

    fi

}

inventory_selector

# Including the inventory completion generator
/srv/scripts/general/generate-inventory-completion.sh