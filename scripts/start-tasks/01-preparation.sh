#!/bin/bash

set -e

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

echo -n -e "${C_CYAN}"

# Creating required files and folders to avoid errors
mkdir -p ./container/home/builder/.history
touch ./container/home/builder/.custom_aliases
touch ./container/home/builder/.personal_aliases
touch .makerc-custom
touch .makerc-personal

echo -n -e "${C_RST}"

# Checking if shell history file exists in legacy path and moving it to the new path
if [ -r ./container/home/builder/.zsh_history ]
then

  mv ./container/home/builder/.zsh_history ./container/home/builder/.history/.zsh_history

fi

# Checking if custom .makerc-vars.example exists and using it if it does
if [ -r custom/.makerc-vars.example  ]
then

    example_vars_file=custom/.makerc-vars.example

  else

    example_vars_file=.makerc-vars.example

fi

# Checking if all of the required variables are present in .makerc-vars
FILE_PATH=$example_vars_file

# Array to store the variables
variables=()

# Flag to indicate if parsing is active
parsing=false

# Read the file line by line
while IFS= read -r line; do
  # Check if parsing is active
  if [ "$parsing" = true ]; then
    # Check if the line matches the end delimiter
    if [[ "$line" == "# REQUIRED_END"* ]]; then
      # Stop parsing
      parsing=false
    else
      # Remove leading and trailing whitespace from the line
      line="${line#"${line%%[![:space:]]*}"}"
      line="${line%"${line##*[![:space:]]}"}"

      # Exclude empty lines and lines starting with #
      if [ -n "$line" ] && [[ ! "$line" =~ ^# ]]; then
        # Extract the content until the first space
        variable="${line%% *}"

        # Add the variable to the array if the environment variable with the same name is empty
        if [ -z "${!variable}" ]; then

          variables+=("$variable")

        fi
      fi
    fi
  else
    # Check if the line matches the start delimiter
    if [[ "$line" == "# REQUIRED_START"* ]]; then
      # Start parsing
      parsing=true
    fi
  fi
done < "$FILE_PATH"

# Print the variables that are not set
for variable in "${variables[@]}"; do

  echo -n -e ${C_RED}
  echo -e "$variable value missing in ${C_YELLOW}${ROOT_DIR}/.makerc-vars${C_RED}"
  echo -n -e ${C_RST}

done