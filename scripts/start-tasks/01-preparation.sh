#!/bin/bash

echo -n -e ${C_CYAN}
echo "Making preparations..."

touch ./container/home/builder/.zsh_history
touch ./container/home/builder/.custom_aliases
touch .makerc-custom
touch .makerc-project
touch .makerc-personal

# Checking if personal docker-compose file exists and creating it if it doesn't
if ! [ -r docker/docker-compose-personal.yml  ]
then

  cp defaults/docker-compose-personal.yml docker/docker-compose-personal.yml

fi

# Checking if custom .makerc-vars.example exists and using it if it does
if [ -r custom/.makerc-vars.example  ]
then

    example_vars_file=custom/.makerc-vars.example

  else

    example_vars_file=.makerc-vars.example

fi

# Checking if .makerc-vars exists
if ! [ -r .makerc-vars  ]
then

  echo -e ${C_RED}
  echo -e ".makerc-vars does not exist."
  echo -n -e ${C_YELLOW}
  echo -e "You can create it with ${C_BLUE}cp $example_vars_file .makerc-vars${C_YELLOW} command."
  echo -e "Make sure to fill out the required variables in .makerc-vars"
  echo -n -e ${C_RST}
  exit 1

fi

# Checking if .makerc-vars has all of the variables that are defined in .makerc-vars.example
echo -e "Validating .makerc-vars..."
new_vars=$(diff <( cat .makerc-vars | grep -v '^#' | grep '=' | cut -d '=' -f 1 |  sort  ) <(cat $example_vars_file | grep -v '^#' | grep '=' | cut -d '=' -f 1 |  sort ) | grep ">" | cut -d ">" -f 2)

if [ ! -z "$new_vars" ]
then
echo -e ${C_RST}
echo -e "${C_CYAN}Found Following variables in ${C_YELLOW}$example_vars_file${C_CYAN} that are not present in ${C_YELLOW}${ROOT_DIR}/.makerc-vars:${C_CYAN}"

  for var in "${new_vars[@]}"
  do
      echo -e ${C_RED}
      stripped_var=$(echo "$var" | cut -d ' ' -f 2)
      echo -e "$stripped_var"
      echo -e ${C_RST}
      echo -n -e ${C_YELLOW}
      echo -e "Even if not used make sure they are present in .makerc-vars"
      echo -e "You can copy them from $example_vars_file just leave the values empty"
      echo -e ${C_RST}
  done
  exit 1
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

# Exiting if any of the required variables are not present
if [[ ! -z "${variables[@]}" ]]
then

  echo -e ${C_YELLOW}
  echo -e "Please make sure all of the required variables are present in .makerc-vars"
  echo -e ${C_RST}
  exit 1

fi

echo -n -e ${C_RST}