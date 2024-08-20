#!/bin/bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

if [ "$1" == "AUTOINSTALL" ]; then

  export CATAPULT_AUTOINSTALL=true
  export MAKEVAR_AUTO_UPDATE=1

fi

# Check if script is run with sudo
if [ $EUID -eq 0 ]; then
    echo -e "${C_RED}"
    echo -e "Don't run this script with sudo, it will ask for sudo password when needed."

    read -rp $'\n'"Press Ctrl + C to cancel or Press ENTER to continue..."
    echo -e "${C_RST}"
else
    # This is to ask sudo password only once at the beginning of the script
    sudo -SE echo -n ""
fi

# Creating .makerc-personal file if it doesn't exist
if [[ ! -f personal/.makerc-personal ]]; then

  echo -n -e "${C_YELLOW}"
  echo -e "Creating personal/.makerc-personal file"
  echo -n -e "${C_RST}"
  mkdir -p personal
  touch personal/.makerc-personal

fi

#########
# MacOS #
#########

if [[ $(uname) == "Darwin" ]]; then
    echo -n -e "${C_YELLOW}"
    echo -e "Removing MacOS sudo requirement for Catapult on MacOS..."
    echo -e "${C_RST}"

    if grep -q "MAKEVAR_SUDO_COMMAND" personal/.makerc-personal; then
        sed -i "" "s#MAKEVAR_SUDO_COMMAND.*#MAKEVAR_SUDO_COMMAND :=#" personal/.makerc-personal
    else
        echo "MAKEVAR_SUDO_COMMAND :=" >> personal/.makerc-personal
    fi

    brew-install() {
        echo -n -e "${C_YELLOW}"
        echo -e "Installing Homebrew..."
        echo -n -e "${C_RST}"
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # shellcheck disable=SC2016
        (echo; echo 'eval "$(/usr/local/bin/brew shellenv)"') >> ~/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
    }

    brew-packages-install() {
        if [[ -x "$(command -v brew)" ]]; then
            echo -n -e "${C_YELLOW}"
            echo -e "Installing MacOS packages with homebrew..."
            echo -n -e "${C_RST}"

            # shellcheck disable=SC2086
            brew install $PACKAGES
        else
            echo -n -e "${C_RED}"
            echo -e "Homebrew not installed, cannot install:"
            echo -e "$PACKAGES"
            echo -n -e "${C_RST}"
            exit 0
        fi
    }

    PACKAGES="git git-lfs make jq curl md5sha1sum"

    echo -n -e "${C_YELLOW}"
    echo -e "Installing homebrew?"
    echo

    if [ -n "$CATAPULT_AUTOINSTALL" ]; then

        brew-install
        brew-packages-install

    else

        options=(
            "Yes"
            "No"
        )

        select _ in "${options[@]}"; do
        case "$REPLY" in
            yes|y|1) brew-install; break;;
            no|n|2) read -rp $'\n'"If you don't install homebrew you'll need to install Docker manually - Press ENTER to continue"$'\n'; break;;
        esac
        done

        echo -n -e "${C_GREEN}"
        echo -e "Installing following packages with homebrew:"
        echo -e "$PACKAGES"
        echo

        options=(
            "Yes"
            "No, I'll install these packages myself"
        )
        select _ in "${options[@]}"; do
        case "$REPLY" in
            yes|y|1) brew-packages-install; break;;
            no|n|2) read -rp $'\n'"Make sure $PACKAGES are installed - Press ENTER to continue"$'\n'; break;;
        esac
        done

  fi

    echo -e "${C_RST}"

fi

#########
# Linux #
#########

if [[ $(uname) == "Linux" ]]; then

  if ! [ -x "$(command -v sudo)" ]; then

    echo -e "${C_RED}"
    echo -e "sudo is not installed, install it and run this script again."
    echo -e "${C_RST}"
    exit 0

  fi


    ###################
    # Debian based OS #
    ###################

    if grep -q "debian" /etc/os-release; then

        PACKAGES="git git-lfs make jq curl sudo gpg ssh"

        debian-packages-install() {
            echo -n -e "${C_YELLOW}"
            echo -e "Installing required deb packages..."
            echo -n -e "${C_RST}"

            sudo -E apt-get update
            # shellcheck disable=SC2068,SC2086
            sudo -E apt-get install $PACKAGES -y

            if [ -n "$WSL_DISTRO_NAME" ]; then
                sudo -E apt-get install keychain -y
            fi
        }

    echo -e "${C_GREEN}"
    echo -e "Installing following packages:"
    echo -e "$PACKAGES"
    echo

    if [ -n "$CATAPULT_AUTOINSTALL" ]; then

      debian-packages-install

    else

        options=(
            "Yes"
            "No, I'll install these packages myself"
        )

        select _ in "${options[@]}"; do
            case "$REPLY" in
            yes|y|1) debian-packages-install; break;;
            no|n|2) read -rp $'\n'"Make sure ${PACKAGES} are installed - Press ENTER to continue"$'\n'; break;;
            esac
        done

    fi

    #############
    # Archlinux #
    #############

    elif grep -q "arch" /etc/os-release; then

        PACKAGES="git git-lfs make jq curl sudo"

        arch-packages-install() {
            echo -n -e "${C_YELLOW}"
            echo -e "Installing required pacman packages..."
            echo -n -e "${C_RST}"

            # shellcheck disable=SC2086
            sudo -E pacman -S $PACKAGES --noconfirm
        }

        echo -e "${C_GREEN}"
        echo -e "Installing following packages:"
        echo -e "$PACKAGES"
        echo -e

        if [ -n "$CATAPULT_AUTOINSTALL" ]; then

            arch-packages-install

        else

        options=(
            "Yes"
            "No, I'll install these packages myself"
        )

        select _ in "${options[@]}"; do
        case "$REPLY" in
            yes|y|1) arch-packages-install; break;;
            no|n|2) read -rp $'\n'"Make sure $PACKAGES are installed - Press ENTER to continue"$'\n'; break;;
        esac
        done

    fi

    ###################
    # RedHat based OS #
    ###################

    elif grep -q "rhel" /etc/os-release; then

        PACKAGES="git git-lfs make jq curl sudo gpg openssh-server dnf-plugins-core"

        rhel-packages-install() {
            echo -n -e "${C_YELLOW}"
            echo -e "Installing required rhel packages..."
            echo -n -e "${C_RST}"

            sudo -E dnf makecache
            # shellcheck disable=SC2086
            sudo -E dnf install $PACKAGES -y
        }

        echo -e "${C_GREEN}"
        echo -e "Installing following packages:"
        echo -e "$PACKAGES"
        echo

        if [ -n "$CATAPULT_AUTOINSTALL" ]; then
        rhel-packages-install
        else
            options=(
                "Yes"
                "No, I'll install these packages myself"
            )

            select _ in "${options[@]}"; do
                case "$REPLY" in
                yes|y|1) rhel-packages-install; break;;
                no|n|2) read -rp $'\n'"Make sure $PACKAGES are installed - Press ENTER to continue"$'\n'; break;;
                esac
            done

        fi

  #########
  # Other #
  #########

  else
        PACKAGES="git git-lfs make jq curl sudo gpg ssh"
        PACKAGES_LFS="git lfs install"

        echo -e "${C_RED}"
        echo -e "You are using unsupported or untested (Linux) operating system. Catapult may still work if you configure it manually"
        echo -e
        echo -e "You'll need to follow these steps:"
        echo -e
        echo -e "1) Install following packages: ${C_YELLOW}$PACKAGES${C_RED}"
        echo -e "2) Initialize git LFS with: ${C_YELLOW}$PACKAGES_LFS${C_RED}"
        echo -e
        read -rp $'\n'"Once you have installed the required packages press any key to continue..."$'\n'
  fi

    echo -e "${C_RST}"

fi

echo -n -e "${C_YELLOW}"
echo "Configuring githooks & LFS..."
echo -n -e "${C_RST}"

touch ~/.gitconfig
git config core.hooksPath .githooks
git lfs install

make prepare
