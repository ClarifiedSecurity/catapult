#!/usr/bin/env bash

# shellcheck disable=SC1091
source /srv/scripts/general/colors.sh

SEARCH_DIR="/srv/inventories"
SEARCH_FOLDER=".git"
FOLDERS=()
while IFS= read -r line; do
  FOLDERS+=("$line")
done < <(find -L "$SEARCH_DIR" \( -type d -o -type l -o -type f \) -name "$SEARCH_FOLDER" -exec dirname {} \; | sort)

#--------------------End of variables, start of script--------------------#

# This function copies the start.yml (playbook file) from /srv/inventories to the selected project folder
# This is done so some of the Ansible's native functionality will work properly (playbook_dir var, project specific plugins, etc.)
function playbook_copy() {

    if grep -qxF "/playbook.yml" "$selected_folder/.gitignore"; then
        echo -n
    else
        echo -ne "${C_YELLOW}"
        echo -e "Adding playbook.yml to .gitignore..."
        echo -e "Don't forget to commit the updated ${C_CYAN}.gitignore${C_YELLOW} file."
        echo -e "\n/playbook.yml" >> "$selected_folder/.gitignore"
        echo -ne "${C_RST}"
    fi

    echo -ne "${C_YELLOW}"
    echo -e "Copying playbook file to ${C_CYAN}$(basename "$selected_folder")${C_YELLOW} project..."

    # Checking if custom start.yml if it exists
    if [[ -f /srv/custom/start.yml ]]; then
        echo -e "Using custom playbook from Catapult Customizer..."
        cp -f /srv/custom/start.yml "$selected_folder/playbook.yml" || echo -e "${C_RED}Failed to copy playbook file.${C_RST}"
    else
        cp -f /srv/defaults/start.yml "$selected_folder/playbook.yml" || echo -e "${C_RED}Failed to copy playbook file.${C_RST}"
    fi

    echo -ne "${C_RST}"
}

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
        playbook_copy
        project_customization_loader
        # shellcheck disable=SC2164
        cd "$selected_folder"

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
            playbook_copy
            project_customization_loader
            # shellcheck disable=SC2164
            cd "$selected_folder"
            touch "/tmp/$(basename "$selected_folder")_hosts" # This is to avoid completion errors if the inventory_generator function fails

        else

            echo -n -e "${C_RED}"
            echo "Invalid project selection."
            echo -n -e "${C_RST}"
            # shellcheck disable=SC2164
            cd /srv

        fi

    else

        echo "No projects found in /srv/inventories or project does not have .git folder."

    fi

}

inventory_selector

# Including the inventory completion generator
/srv/scripts/general/generate-inventory-completion.sh