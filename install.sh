#!/bin/bash

set -e # exit when any command fails

# shellcheck disable=SC1091
source ./scripts/general/colors.sh

# Check if script is run with sudo
if [ $EUID -eq 0 ]; then
    print_nl "${C_RED}"
    print_nl "Don't run this script with sudo, it will ask for sudo password when needed."

    read -rp $'\n'"Press Ctrl + C to cancel or Press any key to continue..."
    print_nl "${C_RST}"
fi

makerc-vars-creator() {
    # Checking if .makerc-vars already exists and asking for an overwrite
    if [ -f .makerc-vars ]; then
        print_nl "${C_RED}"
        print_nl "$(pwd)/.makerc-vars already exists, do you want to overwrite it with $(pwd)/.makerc-vars.example?"
        print_nl "${C_YELLOW}"

        options=(
            "Yes"
            "No"
        )
        select _ in "${options[@]}"; do
            case "$REPLY" in
                yes|y|1) cp -f .makerc-vars.example .makerc-vars; break;;
                no|n|2) print_nl "Not overwriting .makerc-vars"$'\n'; break;;
            esac
        done

        print "${C_RST}"
    else
        cp -f .makerc-vars.example .makerc-vars
    fi
}

if [ ! -f .makerc-vars ]; then
    print_nl "${C_RED}"
    print_nl "$(pwd)/.makerc-vars not found"
    print_nl "${C_YELLOW}"
    print_nl "Do you want to create your .makerc-vars file from the $(pwd)/.makerc-vars.example file?"
    print_nl

    options=(
        "Yes"
        "No, I'm using custom .makerc-vars"
    )
    select _ in "${options[@]}"; do
        case "$REPLY" in
            yes|y|1) makerc-vars-creator; break;;
            no|n|2) read -rp $'\n'"Make sure your $(pwd)/.makerc-vars exists and press any key to continue"$'\n'; break;;
        esac
    done

    print "$C_RST"
else
    makerc-vars-creator
fi

# MacOS
if [[ $(uname) == "Darwin" ]]; then
    print "${C_MAGENTA}"
    print_nl "Removing MacOS sudo requirement for Catapult..."
    print_nl "${C_RST}"

    sed -i "" "s#MAKEVAR_SUDO_COMMAND.*#MAKEVAR_SUDO_COMMAND :=#" .makerc-vars

    brew-install() {
        print "${C_MAGENTA}"
        print_nl "Installing Homebrew..."
        print "${C_RST}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    }

    brew-packages-install() {
        if [[ -x "$(command -v brew)" ]]; then
            print "${C_MAGENTA}"
            print_nl "Installing MacOS packages with homebrew..."
            print "${C_RST}"

            # shellcheck disable=SC2086
            brew install $PACKAGES
        else
            print "${C_RED}"
            print_nl "Homebrew not installed, cannot install:"
            print_nl "$PACKAGES"
            print "${C_RST}"
            exit 0
        fi
    }

    PACKAGES="git git-lfs make jq curl md5sha1sum"

    print "${C_YELLOW}"
    print_nl "Installing homebrew?"
    echo

    options=(
        "Yes"
        "No"
    )

    select _ in "${options[@]}"; do
        case "$REPLY" in
            yes|y|1) brew-install; break;;
            no|n|2) read -rp $'\n'"If you don't install homebrew you'll need to install Docker manually - Press any key to continue"$'\n'; break;;
        esac
    done

    print "${C_YELLOW}"
    print_nl "Installing following packages with homebrew:"
    print_nl "$PACKAGES"
    echo

    options=(
        "Yes"
        "No, I'll install these packages myself"
    )
    select _ in "${options[@]}"; do
        case "$REPLY" in
            yes|y|1) brew-packages-install; break;;
            no|n|2) read -rp $'\n'"Make sure $PACKAGES are installed - Press any key to continue"$'\n'; break;;
        esac
    done

    print_nl "${C_RST}"
fi

# Linux
if [[ $(uname) == "Linux" ]]; then
    if ! [ -x "$(command -v sudo)" ]; then
        print_nl "${C_RED}"
        print_nl "sudo is not installed, install it and run this script again."
        print_nl "${C_RST}"
        exit 0
    fi

    # Debian based OS
    if grep -q "debian" /etc/os-release; then
        PACKAGES="git git-lfs make jq curl sudo gpg ssh"

        debian-packages-install() {
            print "${C_MAGENTA}"
            print_nl "Installing required deb packages..."
            print "${C_RST}"

            sudo -E apt-get update
            # shellcheck disable=SC2068,SC2086
            sudo -E apt-get install $PACKAGES -y

            if [ -n "$WSL_DISTRO_NAME" ]; then
                sudo -E apt-get install keychain -y
            fi
        }

        print_nl "${C_YELLOW}"
        print_nl "Installing following packages:"
        print_nl "$PACKAGES"
        echo

        options=(
            "Yes"
            "No, I'll install these packages myself"
        )
        select _ in "${options[@]}"; do
            case "$REPLY" in
                yes|y|1) debian-packages-install; break;;
                no|n|2) read -rp $'\n'"Make sure ${PACKAGES} are installed - Press any key to continue"$'\n'; break;;
            esac
        done

    # Arch
    elif grep -q "arch" /etc/os-release; then
        PACKAGES="git git-lfs make jq curl sudo"

        arch-packages-install() {
            print "${C_MAGENTA}"
            print_nl "Installing required pacman packages..."
            print "${C_RST}"

            # shellcheck disable=SC2086
            sudo -E pacman -S $PACKAGES --noconfirm
        }

        print_nl "${C_YELLOW}"
        print_nl "Installing following packages:"
        print_nl "$PACKAGES"
        print_nl

        options=(
            "Yes"
            "No, I'll install these packages myself"
        )
        select _ in "${options[@]}"; do
            case "$REPLY" in
                yes|y|1) arch-packages-install; break;;
                no|n|2) read -rp $'\n'"Make sure $PACKAGES are installed - Press any key to continue"$'\n'; break;;
            esac
        done

    # RedHat based OS
    elif grep -q "rhel" /etc/os-release; then
        PACKAGES="git git-lfs make jq curl sudo gpg openssh-server dnf-plugins-core"

        rhel-packages-install() {
            print "${C_MAGENTA}"
            print_nl "Installing required rhel packages..."
            print "${C_RST}"

            sudo -E dnf makecache
            # shellcheck disable=SC2086
            sudo -E dnf install $PACKAGES -y
        }

        print_nl "${C_YELLOW}"
        print_nl "Installing following packages:"
        print_nl "$PACKAGES"
        echo

        options=(
            "Yes"
            "No, I'll install these packages myself"
        )
        select _ in "${options[@]}"; do
            case "$REPLY" in
                yes|y|1) rhel-packages-install; break;;
                no|n|2) read -rp $'\n'"Make sure $PACKAGES are installed - Press any key to continue"$'\n'; break;;
            esac
        done

    # Other
    else
        PACKAGES="git git-lfs make jq curl sudo gpg ssh"
        PACKAGES_LFS="git lfs install"

        print_nl "${C_RED}"
        print_nl "You are using unsupported or untested (Linux) operating system. Catapult may still work if you configure it manually"
        print_nl
        print_nl "You'll need to follow these steps:"
        print_nl
        print_nl "1) Install following packages: ${C_YELLOW}$PACKAGES${C_RED}"
        print_nl "2) Initialize git LFS with: ${C_YELLOW}$PACKAGES_LFS${C_RED}"
        print_nl
        read -rp $'\n'"Once you have installed the required packages press any key to continue..."$'\n'
    fi

    print_nl "${C_RST}"
fi

print "${C_MAGENTA}"
echo "Configuring githooks & LFS..."
print "${C_RST}"

touch ~/.gitconfig
git config core.hooksPath .githooks
git lfs install

make prepare
