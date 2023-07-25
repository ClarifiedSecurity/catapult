#!/bin/bash

set -e

echo -e -n ${C_CYAN}

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

# Checking if the latest remote tag is different than the current local tag
UPSTREAM=main
REMOTE_TAG=$(curl --silent https://api.github.com/repos/ClarifiedSecurity/catapult/tags | jq -r '.[0].name')
LOCAL_TAG=$(git describe --tags --abbrev=0 $UPSTREAM)

catapult_update () {

  LOCAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)

  if [ $LOCAL_BRANCH == "main" ]; then

    git pull

  else

    git fetch origin $UPSTREAM:$UPSTREAM
    echo -e "You are not on the main branch, make sure to rebase your $LOCAL_BRANCH branch with: `git rebase -i origin/$UPSTREAM`"

  fi

}

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

echo -e -n ${C_RST}