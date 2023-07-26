#!/bin/bash

set -e

echo -e -n ${C_CYAN}

# Catalpult update function
catapult_update () {

  LOCAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)

  if [ $LOCAL_BRANCH == "main" ]; then

    git pull

  else

    git fetch origin $UPSTREAM:$UPSTREAM
    echo -e "You are not on the main branch, make sure to rebase your $LOCAL_BRANCH branch with: `git rebase -i origin/$UPSTREAM`"

  fi

}

# Docker image pull function
docker_pull () {

select option in "${options[@]}"; do
    case "$REPLY" in
        yes) ${MAKEVAR_SUDO_COMMAND} docker pull ${IMAGE_FULL}; break;;
        no) echo -e "Not pulling now"; break;;
        y) ${MAKEVAR_SUDO_COMMAND} docker pull ${IMAGE_FULL}; break;;
        n) echo -e "Not pulling now"; break;;
        1) ${MAKEVAR_SUDO_COMMAND} docker pull ${IMAGE_FULL}; break;;
        2) echo -e "Not pulling now"; break;;
    esac
done

}

# Checking if git is installed
if ! [ -x "$(command -v git)" ]; then
  echo -n -e ${C_RED}
  echo -e "Git is not installed!"
  exit 1
fi

# Checking if gituhb is reachable
if ! ping -c 1 github.com &> /dev/null; then
  echo -n -e ${C_YELLOW}
  echo -e "Cannot check for Catapult version!"
  echo -e "GitHub is not reachable"
  exit 0;
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

# Checking if the latest remote tag is different than the current local tag
UPSTREAM=main
REMOTE_TAG=$(curl --silent https://api.github.com/repos/ClarifiedSecurity/catapult/tags | jq -r '.[0].name')
LOCAL_TAG=$(git describe --tags --abbrev=0 $UPSTREAM)

# Checking if remote tag is newer than local tag
if [[ $LOCAL_TAG == $REMOTE_TAG ]]; then

    echo -e -n

  else

    echo -e "Catapult version $REMOTE_TAG is available, do you want to update?"
    options=(
      "yes"
      "no"
    )

    select option in "${options[@]}"; do
        case "$REPLY" in
            yes) catapult_update; break;;
            no) echo -e "Not updating Catapult"; break;;
            y) catapult_update; break;;
            n) echo -e "Not updating Catapult"; break;;
            1) catapult_update; break;;
            2) echo -e "Not updating Catapult"; break;;
        esac
    done

fi

# Checking if personal docker-compose file exists and creating it if it doesn't
if ! [ -r docker/docker-compose-personal.yml  ]
then

  cp defaults/docker-compose-personal.yml docker/docker-compose-personal.yml

fi



# Chcking for docker image updates if ${MAKEVAR_CONTAINER_REGISTRY} is defined
if [[ -z "${MAKEVAR_CONTAINER_REGISTRY}" ]]; then

  echo -n -e ${C_RED}
  echo -e "Cannot check for docker image version, MAKEVAR_CONTAINER_REGISTRY is not defined in .makerc-vars!"
  echo -n -e ${C_CYAN}
  exit 0;

fi

# Checking if ${MAKEVAR_CONTAINER_REGISTRY} is reachable
http_code=$(curl -L https://${MAKEVAR_CONTAINER_REGISTRY} --write-out "%{http_code}" -s -o /dev/null)

if [[ $http_code == 200 ]]
then

    echo -n -e

else

    echo -n -e ${C_RED}
    echo -e "Cannot check for docker image version!"
    echo -e "${MAKEVAR_CONTAINER_REGISTRY} is not reachable"
    echo -n -e ${C_CYAN}
    exit 0;

fi

# Checking if local image exists and pulling if not
if [[ -z "$(${MAKEVAR_SUDO_COMMAND} docker images -q ${IMAGE_FULL})" ]]; then

    echo -n -e ${C_YELLOW}
    echo -e "Local ${IMAGE_FULL} docker image not found"
    echo -e "Would you like to pull it now?"
    echo -n -e ${C_CYAN}
    options=(
        "yes"
        "no"
    )
    docker_pull


else

    # Getting the local image sha256
    local_image_sha256=$(${MAKEVAR_SUDO_COMMAND} docker inspect ${IMAGE_FULL} -f '{{.Id}}')

    # Checking if local image sha256 is present in the remote image manifest
    if [[ -z $(${MAKEVAR_SUDO_COMMAND} docker manifest inspect ${IMAGE_FULL} -v | grep $local_image_sha256) ]]; then

        echo -n -e ${C_YELLOW}
        echo -e "New ${IMAGE_FULL} docker image is available"
        echo -e "Would you like to update now?"
        echo -n -e ${C_CYAN}
        options=(
        "yes"
        "no"
        )
        docker_pull

    fi

fi

echo -e -n ${C_RST}