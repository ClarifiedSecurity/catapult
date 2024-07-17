# Sourcing the general colors script
# shellcheck disable=SC1091
source /srv/scripts/general/colors.sh

# Activating Python virtual environment
export PATH=$HOME/.cargo/bin:$PATH
# shellcheck disable=SC1091
. "$HOME/.venv/bin/activate"

# Keeping history in a separate mounted folder to avoid can't save history errors when exiting the container
HISTFILE=/home/builder/.history/.zsh_history

# Enabling globbing
# This is required for next line to work correctly
setopt glob

# Path to your oh-my-zsh installation.
export ZSH="/home/builder/.oh-my-zsh"

# Theme
export ZSH_THEME="spaceship"

# Sourcing oh-my-zsh
. $ZSH/oh-my-zsh.sh

# Including better history search
if [ -f ~/.fzf.zsh ]; then
    . ~/.fzf.zsh
fi

# Set CATAPULT_SKIP_ENTRYPOINT=1 to skip the entrypoint
# Useful when using the image in CI
if [ "$CATAPULT_SKIP_ENTRYPOINT" != 1 ]; then

    # Secrets unlocker script
    # Can also be used with ctp secrets unlock
    # shellcheck disable=SC1091
    export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault/unlock-vault.sh
    bash /srv/scripts/general/secrets-unlock.sh

    # Initialization tasks and extra entrypoint(s) loader
    bash /srv/scripts/general/docker-entrypoint.sh

fi

# Checking if completions file exists, if not then creating it
if [ -f "/home/builder/autocomplete.sh" ]; then

    echo -n -e "${C_GREEN}"
    echo -e "Sourcing completions..."
    . /home/builder/autocomplete.sh
    echo -n -e "${C_RST}"

else

    echo -n -e "${C_YELLOW}"
    echo -e "Generating completions..."
    /srv/scripts/general/autocomplete_generator.py
    . /home/builder/autocomplete.sh
    echo -n -e "${C_RST}"

fi

# Running inventory selection script
# shellcheck disable=SC1091
. /srv/scripts/general/select-inventory.sh

# Including default aliases
. /srv/container/home/builder/.default_aliases

# Including custom aliases if they exist
if [ -f /srv/custom/container/.custom_aliases ]; then
    . /srv/custom/container/.custom_aliases
fi

# Including personal aliases
if [ -f /srv/personal/.personal_aliases ]; then
    . /srv/personal/.personal_aliases
fi

# Disabling globbing so extra quotes are not required when using Ansible patterns where * is used
setopt noglob
