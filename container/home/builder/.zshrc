# Keeping history in a separate mounted folder to avoid can't save history errors when exiting the container
HISTFILE=/home/builder/.history/.zsh_history

# Path to your oh-my-zsh installation.
export ZSH="/home/builder/.oh-my-zsh"

# Theme
ZSH_THEME="spaceship"

# Enabling globbing
# This is required for next line to work correctly
setopt glob

# Sourcing oh-my-zsh
. $ZSH/oh-my-zsh.sh

# Including better history search
if [ -f ~/.fzf.zsh ]; then
    . ~/.fzf.zsh
fi

# Including default aliases
. /srv/container/home/builder/.default_aliases

# Including custom aliases if they exist
if [ -f /srv/custom/container/.custom_aliases ]; then
    . /srv/custom/container/.custom_aliases
fi

# Including personal aliases
. /srv/personal/.personal_aliases

# Disabling globbing so extra quotes are not required when using Ansible patterns where * is used
setopt noglob

# Sourcing completions
if [ -f /home/builder/autocomplete.sh ]; then
    . /home/builder/autocomplete.sh
fi
