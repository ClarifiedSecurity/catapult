#!/bin/bash

echo -n -e ${C_RST}

set -e # exit when any command fails

KEEPASS_KEY_FILE_PATH="creds.key" # Defaults to Catapult root directory where the file is in .gitignore
KEEPASS_DB_FILE_PATH="creds.kdbx" # Defaults to Catapult root directory where the file is in .gitignore

# Installing KeePassXC
if [[ $(uname) == "Darwin" ]]; then

  brew install keepassxc

fi

if [[ $(uname) == "Linux" ]]; then

  if grep -q "debian" /etc/os-release; then

    apt-get update
    apt-get install keepassxc -y

  elif grep -q "arch" /etc/os-release; then

    pacman -S keepassxc --noconfirm

  fi

fi

# Checking if keepassxc-cli is installed
if ! [ -x "$(command -v keepassxc-cli)" ]; then

  echo -n -e ${C_RED}
  echo -e "keepassxc-cli is not installed!"
  echo -e "Make sure that KeePassXC & keepassxc-cli is installed!"
  echo -n -e ${C_RST}
  exit 1

fi

# Creating a database keyfile if it does not exist
if [[ ! -f $KEEPASS_KEY_FILE_PATH ]]; then

  echo -n -e ${C_MAGENTA}
  echo "Creating database key..."
  echo -n -e ${C_RST}

  # Creating database key
  dd if=/dev/urandom of=$KEEPASS_KEY_FILE_PATH bs=1 count=2048

else

  echo -n -e ${C_MAGENTA}
  echo "Database key already exists"
  echo -n -e ${C_RST}

fi

# Creating a keepass database if it does not exist
if [[ ! -f $KEEPASS_DB_FILE_PATH ]]; then

  while true; do

      echo -n -e ${C_YELLOW}
      read -s -p "Enter password to encrypt database: " KDBX_PASSWORD1
      echo

      read -s -p "Repeat password: " KDBX_PASSWORD2
      echo
      echo -n -e ${C_RST}

      # Check if the passwords match
      if [ "$KDBX_PASSWORD1" != "$KDBX_PASSWORD2" ]; then

          echo -n -e ${C_RED}
          echo "Passwords do not match, try again"
          echo -n -e ${C_RST}

      else

          KDBX_PASSWORD="$KDBX_PASSWORD1"
          break  # Exit the loop if passwords match

      fi

  done

  echo -n -e ${C_MAGENTA}
  echo "Creating database..."
  echo -n -e ${C_RST}

  # Creating database
  echo -e "$KDBX_PASSWORD\n$KDBX_PASSWORD" | keepassxc-cli db-create --set-key-file=$KEEPASS_KEY_FILE_PATH --set-password $KEEPASS_DB_FILE_PATH

  # Creating DEPLOYER_CREDENTIALS entry
  echo -e "$KDBX_PASSWORD" | keepassxc-cli add --key-file $KEEPASS_KEY_FILE_PATH $KEEPASS_DB_FILE_PATH DEPLOYER_CREDENTIALS

else

  echo -n -e ${C_MAGENTA}
  echo "Database already exists"
  echo -n -e ${C_RST}

fi

chown -R $CONTAINER_USER_NAME $KEEPASS_DB_FILE_PATH
chown -R $CONTAINER_USER_NAME $KEEPASS_KEY_FILE_PATH

KEEPASS_DB_FILE_PATH_FULLPATH=$(readlink -f $KEEPASS_DB_FILE_PATH)
KEEPASS_KEY_FILE_PATH_FULLPATH=$(readlink -f $KEEPASS_KEY_FILE_PATH)

# Setting the correct values for .makerc-vars
echo -n -e ${C_MAGENTA}
echo "Updating values in .makerc-vars..."
echo -n -e ${C_RST}

sed -i'' -e "s#KEEPASS_DB_PATH.*#KEEPASS_DB_PATH :=$KEEPASS_DB_FILE_PATH_FULLPATH#" ${ROOT_DIR}/.makerc-vars
sed -i'' -e "s#KEEPASS_KEY_PATH.*#KEEPASS_KEY_PATH :=$KEEPASS_KEY_FILE_PATH_FULLPATH#" ${ROOT_DIR}/.makerc-vars
sed -i'' -e "s#KEEPASS_DEPLOYER_CREDENTIALS_PATH.*#KEEPASS_DEPLOYER_CREDENTIALS_PATH :=DEPLOYER_CREDENTIALS#" ${ROOT_DIR}/.makerc-vars

echo -e ${C_YELLOW}
echo -e "Your database is located at $KEEPASS_DB_FILE_PATH_FULLPATH"
echo -e "Your database key is located at $KEEPASS_KEY_FILE_PATH_FULLPATH"
echo
echo -e "Open your database with the KeePassXC GUI and fill out the DEPLOYER_CREDENTIALS entry with your credentials"
echo -n -e ${C_RST}
