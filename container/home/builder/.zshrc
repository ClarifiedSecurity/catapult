# Sourcing the general colors script
# shellcheck disable=SC1091
source /srv/scripts/general/colors.sh

# Activating Python virtual environment
source "$HOME/.local/bin/env"
source "$HOME/catapult-venv/.venv/bin/activate"

# Keeping history in a separate mounted folder to avoid can't save history errors when exiting the container
HISTFILE=/home/builder/.history/.zsh_history

# Enabling globbing
# This is required for next line to work correctly
setopt glob

# Path to your oh-my-zsh installation.
export ZSH="/home/builder/.oh-my-zsh"

# Load the vcs_info function for Git branch info
autoload -Uz vcs_info

# Track command start time with milliseconds
preexec() {
    # Use date with nanosecond precision and convert to milliseconds
    cmd_start_time=$(date +%s%N)
}

# Update vcs_info and calculate command execution time
precmd() {
    # Update the vcs_info
    vcs_info

    # Calculate the elapsed time if the command start time is set
    if [[ -n $cmd_start_time ]]; then
        cmd_end_time=$(date +%s%N)

        # Calculate the difference in nanoseconds, then convert to seconds
        difference_ns=$((cmd_end_time - cmd_start_time))
        difference=$((difference_ns / 1000000000)) # Convert nanoseconds to seconds

        # Get milliseconds from nanoseconds
        milliseconds=$(((difference_ns / 1000000) % 1000)) # 1,000,000 ns = 1 ms

        # Convert the difference to hours, minutes and seconds
        hours=$(( difference / 3600 ))
        minutes=$(( (difference % 3600) / 60 ))
        seconds=$(( difference % 60 ))

        # Format the elapsed time
        elapsed_time="${hours}h ${minutes}m ${seconds}s ${milliseconds}ms"

        unset cmd_start_time

    else
        elapsed_time=""
    fi

    # Checking if local branch is behind the remote
    BEHIND=$(command git rev-list --count HEAD..${git_branch}@{upstream} 2>/dev/null)
    if (( $BEHIND )); then
        git_status="⇣"
    else
        git_status=""
    fi

}

# Set the format for vcs_info (this determines how the Git branch is displayed)
zstyle ':vcs_info:git:*' formats ' (%b)'

# Define the prompt, including hostname, current directory, Git branch, and command time
PROMPT='%F{green}%m %F{blue}%1~%F{yellow}${vcs_info_msg_0_}%F{red}${git_status} %F{cyan}${elapsed_time}%f
%F{red}➜%f '

# Sourcing oh-my-zsh
. $ZSH/oh-my-zsh.sh

# Including better history search
if [ -f ~/.fzf.zsh ]; then
    . ~/.fzf.zsh
fi

# Secrets unlock script
# Can also be used with ctp secrets unlock
export ANSIBLE_VAULT_PASSWORD_FILE=$HOME/.vault/unlock-vault.sh
bash /srv/scripts/general/secrets-unlock.sh

# Running first run tasks
if [[ ! -f /tmp/first-run ]]; then

    # Running IPv(4|6) connectivity check
    /srv/scripts/general/check-connectivity.sh

    # Trusting custom certificates if they are present
    if [[ -d "/srv/custom/certificates" && "$(ls -A /srv/custom/certificates)" ]]; then

      echo -e "${C_YELLOW}Trusting custom certificates...${C_RST}"
      sudo rsync -ar /srv/custom/certificates/ /usr/local/share/ca-certificates/ --ignore-existing
      touch /tmp/trust_extra_certificates

    fi

    # Trusting personal certificates if they are present
    if [[ -d "/srv/personal/certificates" && "$(ls -A /srv/personal/certificates)" ]]; then

      echo -e "${C_YELLOW}Trusting personal certificates...${C_RST}"
      sudo rsync -ar /srv/personal/certificates/ /usr/local/share/ca-certificates/ --ignore-existing
      touch /tmp/trust_extra_certificates

    fi

    # Updating certificates if needed
    if [[ -f /tmp/trust_extra_certificates ]]; then

      sudo update-ca-certificates > /dev/null 2>/dev/null # To avoid false positive error rehash: warning: skipping ca-certificates.crt,it does not contain exactly one certificate or CRL

    fi

    # Creating the file to avoid errors when it's not present for CI pipelines for an example
    sudo touch /ssh-agent

    # Making sure that /ssh-agent has the correct permissions
    # Required mostly for MacOS and Linux with non 1000 user host
    sudo chmod 775 /ssh-agent
    sudo chown "${CONTAINER_USER_ID}":"$(id -g)" /ssh-agent

    ################################
    # FIRST RUN ENTRYPOINT SCRIPTS #
    ################################

    # Loading first-run personal docker entrypoints if they are present
    if [[ -d "/srv/personal/docker-entrypoints/first-run" && "$(ls -A /srv/personal/docker-entrypoints/first-run)" ]]; then

        for personal_entrypoint in /srv/personal/docker-entrypoints/first-run/*; do
            if [[ -f $personal_entrypoint && $personal_entrypoint == *.sh ]]; then
            # Comment in the echo line below for better debugging
            # echo -e "\n     Processing $personal_entrypoint...\n"
            . $personal_entrypoint
            fi
        done

    fi

    # Loading first-run custom docker entrypoints if they are present
    if [[ -d "/srv/custom/docker-entrypoints/first-run" && "$(ls -A /srv/custom/docker-entrypoints/first-run)" ]]; then

        for custom_entrypoint in /srv/custom/docker-entrypoints/first-run/*; do
            if [[ -f $custom_entrypoint && $custom_entrypoint == *.sh ]]; then
            # Comment in the echo line below for better debugging
            # echo -e "\n     Processing $custom_entrypoint...\n"
            . $custom_entrypoint
            fi
        done

    fi

    # Loading first-run default docker entrypoints
    for entrypoint in /srv/scripts/entrypoints/first-run/*; do
      if [[ -f $entrypoint && $entrypoint == *.sh ]]; then
        # Comment in the echo line below for better debugging
        # echo -e "\n     Processing $entrypoint...\n"
        . $entrypoint
      fi
    done

    # Creating first run file
    touch /tmp/first-run

fi

################################
# EVERY RUN ENTRYPOINT SCRIPTS #
################################

# Loading every-run personal docker entrypoints if they are present
if [[ -d "/srv/personal/docker-entrypoints/every-run" && "$(ls -A /srv/personal/docker-entrypoints/every-run)" ]]; then

    for personal_entrypoint in /srv/personal/docker-entrypoints/every-run/*; do
        if [[ -f $personal_entrypoint && $personal_entrypoint == *.sh ]]; then
        # Comment in the echo line below for better debugging
        # echo -e "\n     Processing $personal_entrypoint...\n"
        . $personal_entrypoint
        fi
    done

fi

# Loading every-run custom docker entrypoints if they are present
if [[ -d "/srv/custom/docker-entrypoints/every-run" && "$(ls -A /srv/custom/docker-entrypoints/every-run)" ]]; then

    for custom_entrypoint in /srv/custom/docker-entrypoints/every-run/*; do
        if [[ -f $custom_entrypoint && $custom_entrypoint == *.sh ]]; then
        # Comment in the echo line below for better debugging
        # echo -e "\n     Processing $custom_entrypoint...\n"
        . $custom_entrypoint
        fi
    done

fi

# Loading every-run default docker entrypoints
if [[ -d "/srv/scripts/entrypoints/every-run" && "$(ls -A /srv/scripts/entrypoints/every-run)" ]]; then

    for entrypoint in /srv/scripts/entrypoints/every-run/*; do
        if [[ -f $entrypoint && $entrypoint == *.sh ]]; then
        # Comment in the echo line below for better debugging
        # echo -e "\n     Processing $entrypoint...\n"
        . $entrypoint
        fi
    done

fi

echo -n -e "${C_RST}"

# Checking if completions file exists, if not then creating it
if [[ -f "$HOME/autocomplete.zsh" ]]; then

    echo -n -e "${C_YELLOW}"
    echo -e "Sourcing completions..."
    . $HOME/autocomplete.zsh
    echo -n -e "${C_RST}"

else

    echo -n -e "${C_YELLOW}"
    echo -e "Generating completions..."
    /srv/scripts/general/autocomplete_generator.py
    . $HOME/autocomplete.zsh
    echo -n -e "${C_RST}"

fi

# Running inventory selection script
# shellcheck disable=SC1091
. /srv/scripts/general/select-inventory.sh

# Including default zsh aliases and functions
. /srv/container/home/builder/.default_aliases

# Including custom zsh aliases and functions if they exist
if [[ -f /srv/custom/container/.custom_aliases ]]; then
    . /srv/custom/container/.custom_aliases
fi

# Including personal zsh aliases and functions if they exist
if [[ -f /srv/personal/.personal_aliases ]]; then
    . /srv/personal/.personal_aliases
fi

setopt noglob # Disabling globbing so extra quotes are not required when using Ansible patterns where * is used
setopt NO_BANG_HIST # Disabling history expansion with ! to avoid issues with Ansible commands

# Create a global alias for & so it's not treated as a background process runner
alias -g '&'='\&'