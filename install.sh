#!/bin/bash

set -e # exit when any command fails

C_RED="\033[31m"
C_GREEN="\033[32m"
C_YELLOW="\033[33m"
C_MAGENTA="\033[95m"
C_RST="\033[0m"

# Check if script is run with sudo
if [ $EUID -eq 0 ]; then

    echo -e ${C_RED}
    echo -e "Don't run this script with sudo, it will ask for sudo password when needed."

    read -p $'\n'"Press Ctrl + C to cancel or Press any key to continue..."
    echo -e ${C_RST}

fi

makerc-vars-creator() {

# Checking if .makerc-vars already exists and asking for an overwrite
if [ -f .makerc-vars ]; then

    echo -e ${C_RED}
    echo -e "$(pwd)/.makerc-vars already exists, do you want to overwrite it with $(pwd)/.makerc-vars.example?"
    echo -e ${C_YELLOW}

    options=(
        "Yes"
        "No"
    )

    select option in "${options[@]}"; do
        case "$REPLY" in
            yes|y|1) cp -f .makerc-vars.example .makerc-vars; break;;
            no|n|2) echo -e "Not overwriting .makerc-vars"$'\n'; break;;
        esac
    done

    echo -n -e ${C_RST}

else

    cp -f .makerc-vars.example .makerc-vars

fi

}

if [ ! -f .makerc-vars ]; then

    echo -e ${C_RED}
    echo -e "$(pwd)/.makerc-vars not found"
    echo -e ${C_YELLOW}
    echo -e "Do you want to create your .makerc-vars file from the $(pwd)/.makerc-vars.example file?"
    echo -e

    options=(
        "Yes"
        "No, I'm using custom .makerc-vars"
    )

    select option in "${options[@]}"; do
        case "$REPLY" in
            yes) makerc-vars-creator; break;;
            no) read -p $'\n'"Make sure your $(pwd)/.makerc-vars exists and press any key to continue"$'\n'; break;;
            y) makerc-vars-creator; break;;
            n) read -p $'\n'"Make sure your $(pwd)/.makerc-vars exists and press any key to continue"$'\n'; break;;
            1) makerc-vars-creator; break;;
            2) read -p $'\n'"Make sure your $(pwd)/.makerc-vars exists and press any key to continue"$'\n'; break;;
        esac
    done

    echo -n -e $C_RST

else

    makerc-vars-creator

fi

# MacOS
if [[ $(uname) == "Darwin" ]]; then

    echo -n -e ${C_MAGENTA}
    echo -e "Removing MacOS sudo requirement for Catapult..."
    echo -e ${C_RST}

    sed -i "" "s#MAKEVAR_SUDO_COMMAND.*#MAKEVAR_SUDO_COMMAND :=#" .makerc-vars

    brew-install() {

        echo -n -e ${C_MAGENTA}
        echo -e "Installing Homebrew..."
        echo -n -e ${C_RST}
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    }

    brew-packages-install() {


        if [[ -x "$(command -v brew)" ]]; then

            echo -n -e ${C_MAGENTA}
            echo -e "Installing MacOS packages with homebrew..."
            echo -n -e ${C_RST}

            brew install ${BREW_PACKAGES[@]}

        else

            echo -n -e ${C_RED}
            echo -e "Homebrew not installed, cannot install:"
            echo -e "$BREW_PACKAGES"
            echo -n -e ${C_RST}
            exit 0

        fi

    }

    BREW_PACKAGES="git git-lfs make jq curl md5sha1sum"

    echo -n -e ${C_YELLOW}
    echo -e "Installing homebrew?"
    echo -e

    options=(
        "Yes"
        "No"
    )

    select option in "${options[@]}"; do
        case "$REPLY" in
            yes) brew-install; break;;
            no) read -p $'\n'"If you don't install homebrew you'll need to install Docker manually - Press any key to continue"$'\n'; break;;
            y) brew-install; break;;
            n) read -p $'\n'"If you don't install homebrew you'll need to install Docker manually - Press any key to continue"$'\n'; break;;
            1) brew-install; break;;
            2) read -p $'\n'"If you don't install homebrew you'll need to install Docker manually - Press any key to continue"$'\n'; break;;
        esac
    done

    echo -e ${C_RST}

    echo -n -e ${C_YELLOW}
    echo -e "Installing following packages with homebrew:"
    echo -e $BREW_PACKAGES
    echo -e

    options=(
        "Yes"
        "No, I'll install these packages myself"
    )

    select option in "${options[@]}"; do
        case "$REPLY" in
            yes) brew-packages-install; break;;
            no) read -p $'\n'"Make sure $BREW_PACKAGES are installed - Press any key to continue"$'\n'; break;;
            y) brew-packages-install; break;;
            n) read -p $'\n'"Make sure $BREW_PACKAGES are installed - Press any key to continue"$'\n'; break;;
            1) brew-packages-install; break;;
            2) read -p $'\n'"Make sure $BREW_PACKAGES are installed - Press any key to continue"$'\n'; break;;
        esac
    done

    echo -e ${C_RST}

fi

# Linux
if [[ $(uname) == "Linux" ]]; then

    if ! [ -x "$(command -v sudo)" ]; then

    echo -e ${C_RED}
    echo -e "sudo is not installed, install it and run this script again."
    echo -e ${C_RST}
    exit 0

    fi

    # Debian based OS
    if grep -q "debian" /etc/os-release; then

        DEBIAN_PACKAGES="git git-lfs make jq curl sudo gpg ssh"

        debian-packages-install() {

            echo -n -e ${C_MAGENTA}
            echo -e "Installing required deb packages..."
            echo -n -e ${C_RST}

            sudo -E apt-get update
            sudo -E apt-get install $DEBIAN_PACKAGES -y

            if [ -n "$WSL_DISTRO_NAME" ]; then

                sudo -E apt-get update
                sudo -E apt-get install keychain -y

            fi

        }

        echo -e ${C_YELLOW}
        echo -e "Installing following packages:"
        echo -e $DEBIAN_PACKAGES
        echo -e

        options=(
            "Yes"
            "No, I'll install these packages myself"
        )

        select option in "${options[@]}"; do
            case "$REPLY" in
                yes) debian-packages-install; break;;
                no) read -p $'\n'"Make sure $DEBIAN_PACKAGES are installed - Press any key to continue"$'\n'; break;;
                y) debian-packages-install; break;;
                n) read -p $'\n'"Make sure $DEBIAN_PACKAGES are installed - Press any key to continue"$'\n'; break;;
                1) debian-packages-install; break;;
                2) read -p $'\n'"Make sure $DEBIAN_PACKAGES are installed - Press any key to continue"$'\n'; break;;
            esac
        done

        echo -e ${C_RST}

    # Arch
    elif grep -q "arch" /etc/os-release; then


        ARCH_PACKAGES="git git-lfs make jq curl sudo"

        arch-packages-install() {

            echo -n -e ${C_MAGENTA}
            echo -e "Installing required pacman packages..."
            echo -n -e ${C_RST}

            sudo -E pacman -S $ARCH_PACKAGES --noconfirm

        }

        echo -e ${C_YELLOW}
        echo -e "Installing following packages:"
        echo -e $ARCH_PACKAGES
        echo -e

        options=(
            "Yes"
            "No, I'll install these packages myself"
        )

        select option in "${options[@]}"; do
            case "$REPLY" in
                yes) arch-packages-install; break;;
                no) read -p $'\n'"Make sure $ARCH_PACKAGES are installed - Press any key to continue"$'\n'; break;;
                y) arch-packages-install; break;;
                n) read -p $'\n'"Make sure $ARCH_PACKAGES are installed - Press any key to continue"$'\n'; break;;
                1) arch-packages-install; break;;
                2) read -p $'\n'"Make sure $ARCH_PACKAGES are installed - Press any key to continue"$'\n'; break;;
            esac
        done

        echo -e ${C_RST}

    # Other
    else

        echo -n -e ${C_RED}
        echo -e
        echo -e "You are using unsupported or untested (Linux) operating system. Catapult may still work if you configure it manually"
        echo -e "You'll need to follow these steps:"
        echo -e
        echo -e "1) Install following packages: ${C_YELLOW}git git-lfs make jq curl sudo gpg ssh${C_RED}"
        echo -e "2) Initialize git LFS with: ${C_YELLOW}git lfs install${C_RED}"
        echo -e
        read -p $'\n'"Once you have installed the required packages press any key to continue..."$'\n'
        echo -e ${C_RST}


    fi

fi

echo -n -e ${C_MAGENTA}
echo -e "Configuring githooks & LFS..."
echo -n -e ${C_RST}

touch ~/.gitconfig
git config core.hooksPath .githooks
git lfs install

make prepare