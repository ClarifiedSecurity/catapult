# Keeping history in a separate mounted folder to avoid can't save history errors when exiting the container
HISTFILE=/home/builder/.history/.zsh_history
LIST_MAX=10000

# Path to your oh-my-zsh installation.
export ZSH="/home/builder/.oh-my-zsh"

# Theme
ZSH_THEME="spaceship"

# Enabling globbing
# This is required for next line to work correctly
setopt glob

# Sourcing oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Including better history
if [ -f ~/.fzf.zsh ]; then
    . ~/.fzf.zsh
fi

# Disabling globbing so extra quotes are not required when using Ansible patterns where * is used
setopt noglob

# Sourcing completions
source /home/builder/autocomplete.sh